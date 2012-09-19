#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"
#import "NSObject+JFFJsonObjectValidator.h"

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
