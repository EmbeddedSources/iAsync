#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"

#include <vector>

#include <objc/runtime.h>

static BOOL isClass(id object)
{
    return class_isMetaClass(object_getClass(object));
}

static NSArray *allJsonTypes(void)
{
    static NSArray *allJsonTypes;
    if (!allJsonTypes)
    {
        allJsonTypes = @[
        [NSString     class],
        [NSNumber     class],
        [NSDictionary class],
        [NSArray      class],
        [NSNull       class],
        ];
    }
    return allJsonTypes;
}

static BOOL isJsonObject(id object)
{
    BOOL result = [allJsonTypes() firstMatch:^BOOL(id classElement)
    {
        BOOL result = [object isKindOfClass:classElement];
        return result;
    }] != nil;

    return result;
}

@implementation NSObject (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPatternValue:(id)jsonPattern
                      rootJsonObject:(id)rootJsonObject
                     rootJsonPattern:(id)rootJsonPattern
                               error:(NSError *__autoreleasing *)outError
{
    if (!isClass(jsonPattern) && ![self isEqual:jsonPattern])
    {
        if (outError)
        {
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

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError
{
    if (![self isKindOfClass:[jsonPattern class]])
    {
        if (outError)
        {
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
    return NO;
}

@end

@implementation JFFJsonObjectValidator

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
            rootJsonObject:(id)rootJsonObject
           rootJsonPattern:(id)rootJsonPattern
                     error:(NSError *__autoreleasing *)outError
{
    NSParameterAssert(jsonObject );
    NSParameterAssert(jsonPattern);
    NSParameterAssert(isJsonObject(jsonObject));

    return [jsonObject validateWithJsonPattern:jsonPattern
                                rootJsonObject:rootJsonObject
                               rootJsonPattern:rootJsonPattern
                                         error:outError];

    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        NSArray *arrayJsonObject = jsonObject;

        static NSArray *allJsonTypes;
        if (!allJsonTypes)
        {
            allJsonTypes = @[
            [NSString     class],
            [NSNumber     class],
            [NSDictionary class],
            [NSArray      class],
            [NSNull       class],
            ];
        }

        NSArray *allowedJsonTypes = [jsonPattern count]==0?allJsonTypes:jsonPattern;

        id objectWithUnexpectedType = [arrayJsonObject firstMatch:^BOOL(id object)
        {
            return ![allowedJsonTypes containsObject:[object class]];
        }];

        if (objectWithUnexpectedType)
        {
            if (outError)
            {
                JFFJsonValidationError *error = [JFFJsonValidationError new];
                error.jsonObject  = rootJsonObject ;
                error.jsonPattern = rootJsonPattern;

                static NSString *const messageFormat = @"jsonObject: %@ does not match types: %@";
                error.message = [[NSString alloc]initWithFormat:messageFormat,
                                 objectWithUnexpectedType,
                                 allowedJsonTypes];

                *outError = error;
            }
            return NO;
        }

        return YES;
    }

//    if ([jsonObject isKindOfClass:[jsonPattern class]])
//    {
//    }

    return NO;
}

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
                     error:(NSError *__autoreleasing *)outError
{
    return [self validateJsonObject:jsonObject
                    withJsonPattern:jsonPattern
                     rootJsonObject:jsonObject
                    rootJsonPattern:jsonPattern
                              error:outError];
}

@end
