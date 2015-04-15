#import "JFFJsonValidator.h"

#import "NSObject+JFFJsonObjectValidator.h"

#import "JFFOptionalObjectFieldKey.h"
#import "JFFOptionalObjectFieldValue.h"

static NSArray *allJsonTypes(void)
{
    static NSArray *allJsonTypes;
    if (!allJsonTypes) {
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
    BOOL result = [allJsonTypes() any:^BOOL(id classElement) {
        BOOL result = [object isKindOfClass:classElement];
        return result;
    }];
    
    return result;
}

id jOptionalKey(id object)
{
    return [JFFOptionalObjectFieldKey newOptionalObjectFieldWithFieldKey:object];
}

id jOptionalValue(id object)
{
    return [JFFOptionalObjectFieldValue newOptionalObjectFieldWithFieldValue:object];
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
