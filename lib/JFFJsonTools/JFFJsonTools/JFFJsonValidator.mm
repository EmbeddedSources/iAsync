#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"

#include <vector>

@implementation JFFJsonObjectValidator

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
            rootJsonObject:(id)rootJsonObject
           rootJsonPattern:(id)rootJsonPattern
                     error:(NSError *__autoreleasing *)outError
{
    NSParameterAssert(jsonPattern);

    if (![jsonObject isKindOfClass:[jsonPattern class]])
    {
        if (outError)
        {
            JFFJsonValidationError *error = [JFFJsonValidationError new];
            error.jsonObject  = rootJsonObject ;
            error.jsonPattern = rootJsonPattern;

            static NSString *const messageFormat = @"jsonObject: %@ does not match type: %@";
            error.message = [[NSString alloc]initWithFormat:messageFormat,
                             jsonObject,
                             [jsonPattern class]];

            *outError = error;
        }
        return NO;
    }

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
