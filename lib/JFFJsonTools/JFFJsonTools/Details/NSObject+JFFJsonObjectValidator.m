#import "NSObject+JFFJsonObjectValidator.h"

#import "JFFOptionalObjectField.h"
#import "JFFJsonValidationError.h"

#include <objc/runtime.h>
#include <objc/message.h>

static BOOL isClass(id object)
{
    return class_isMetaClass(object_getClass(object));
}

@implementation NSObject (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPatternValue:(id)jsonPattern
                      rootJsonObject:(id)rootJsonObject
                     rootJsonPattern:(id)rootJsonPattern
                               error:(NSError *__autoreleasing *)outError
{
    if (!isClass(jsonPattern) && ![self isEqual:jsonPattern]) {
        if (outError) {
            JFFJsonValidationError *error = [JFFJsonValidationError new];
            error.jsonObject  = rootJsonObject ;
            error.jsonPattern = rootJsonPattern;
            
            static NSString *const messageFormat = @"jsonObject: %@ does not match value: %@";
            error.message = [[NSString alloc]initWithFormat:messageFormat,
                             self,
                             jsonPattern];
            
            *outError = error;
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)validateWithJsonPatternClass:(id)jsonPattern
                      rootJsonObject:(id)rootJsonObject
                     rootJsonPattern:(id)rootJsonPattern
                               error:(NSError *__autoreleasing *)outError
{
    Class checkClass = isClass(jsonPattern)?jsonPattern:[jsonPattern class];
    checkClass = [checkClass jffMeaningClass];
    
    SEL selector = isClass(self)?@selector(isSubclassOfClass:):@selector(isKindOfClass:);
    
    if (!objc_msgSend(self, selector, checkClass)) {
        if (outError) {
            JFFJsonValidationError *error = [JFFJsonValidationError new];
            error.jsonObject  = rootJsonObject ;
            error.jsonPattern = rootJsonPattern;
            
            static NSString *const messageFormat = @"jsonObject: %@ does not match type: %@";
            error.message = [[NSString alloc]initWithFormat:messageFormat,
                             self,
                             [jsonPattern class]];
            
            *outError = error;
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError
{
    if (![self validateWithJsonPatternClass:jsonPattern
                             rootJsonObject:rootJsonObject
                            rootJsonPattern:rootJsonPattern
                                      error:outError]) {
        return NO;
    }

    return [self validateWithJsonPatternValue:jsonPattern
                               rootJsonObject:rootJsonObject
                              rootJsonPattern:rootJsonPattern
                                        error:outError];
}

@end

@implementation NSNull (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError
{
    return [self validateWithJsonPatternValue:jsonPattern
                               rootJsonObject:rootJsonObject
                              rootJsonPattern:rootJsonPattern
                                        error:outError];
}

@end

@implementation NSArray (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError
{
    if (![self validateWithJsonPatternClass:jsonPattern
                             rootJsonObject:rootJsonObject
                            rootJsonPattern:rootJsonPattern
                                      error:outError]) {
        return NO;
    }
    
    if (!isClass(jsonPattern)) {
        if ([jsonPattern count] == 1) {
            //all elements should have a given class
            for (id subElement in self) {
                if (![subElement validateWithJsonPattern:jsonPattern[0]
                                          rootJsonObject:rootJsonObject
                                         rootJsonPattern:rootJsonPattern
                                                   error:outError]) {
                    return NO;
                }
            }
            return YES;
        }
        
        if ([jsonPattern count]!=[self count]) {
            if (outError) {
                JFFJsonValidationError *error = [JFFJsonValidationError new];
                error.jsonObject  = rootJsonObject ;
                error.jsonPattern = rootJsonPattern;
                
                static NSString *const messageFormat = @"jsonObject: %@ does not match array: %@";
                error.message = [[NSString alloc]initWithFormat:messageFormat,
                                 self,
                                 jsonPattern];
                
                *outError = error;
            }
            return NO;
        }
        
        for (NSUInteger index = 0; index < [self count]; ++index) {
            id subPattern = jsonPattern[index];
            id subObject  =        self[index];
            
            if (![subObject validateWithJsonPattern:subPattern
                                     rootJsonObject:rootJsonObject
                                    rootJsonPattern:rootJsonPattern
                                              error:outError])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

@end

@implementation NSDictionary (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError
{
    if (![self validateWithJsonPatternClass:jsonPattern
                             rootJsonObject:rootJsonObject
                            rootJsonPattern:rootJsonPattern
                                      error:outError])
    {
        return NO;
    }
    
    if (isClass(jsonPattern))
    {
        return YES;
    }
    
    __block BOOL result = YES;
    __block NSError *tmpError;
    
    [jsonPattern enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         id patternKey = key;
         
         BOOL isOptionalObjectField = [key isKindOfClass:[JFFOptionalObjectField class]];
         
         if (isOptionalObjectField) {
             patternKey = [key fieldKey];
         }
         
         id subElement = self[patternKey];
         
         if (subElement == nil && isOptionalObjectField) {
             return;
         }
         
         if (!subElement) {
             //set error
             {
                 JFFJsonValidationError *error = [JFFJsonValidationError new];
                 error.jsonObject  = rootJsonObject ;
                 error.jsonPattern = rootJsonPattern;
                 
                 static NSString *const messageFormat = @"jsonObject: %@ has no a field named: %@, see pattern: %@";
                 error.message = [[NSString alloc]initWithFormat:messageFormat,
                                  self,
                                  patternKey,
                                  jsonPattern];
                 
                 tmpError = error;
             }
             
             result = NO;
             *stop = YES;
         }
         
         if (![subElement validateWithJsonPattern:obj
                                   rootJsonObject:rootJsonObject
                                  rootJsonPattern:rootJsonPattern
                                            error:&tmpError]) {
             result = NO;
             *stop = YES;
         }
     }];
    
    [tmpError setToPointer:outError];
    
    return result;
}

@end
