#import "JFFTwitterResponseError+TweetsJSONParser.h"

#import "JFFTwitterDirectMessageAlreadySentError.h"

@implementation JFFTwitterDirectMessageAlreadySentError (TweetsJSONParser)

+ (BOOL)isMineTwitterResponseError:(NSDictionary *)errorJsonObject
{
    if (![errorJsonObject isKindOfClass:[NSDictionary class]])
        return NO;
    
    NSNumber *code = errorJsonObject[@"code"];
    
    if (![code isKindOfClass:[NSNumber class]])
        return NO;
    
    if ([code unsignedIntegerValue] == 151)
        return YES;
    
    return NO;
}

@end

@implementation JFFTwitterResponseError (TweetsJSONParser)

+ (instancetype)newTwitterResponseErrorWithTwitterJSONObject:(NSDictionary *)jsonObject
                                                     context:(id<NSCopying>)context
{
    if (![jsonObject isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSDictionary *error = [jsonObject[@"errors"] firstObject];
    
    if (!error) {
        
        return nil;
    }
    
    Class classes[] = {[JFFTwitterDirectMessageAlreadySentError class]};
    
    Class resultClass = Nil;
    
    for (size_t index = 0; index < sizeof(classes)/sizeof(classes[0]); ++index) {
        
        Class currentClass = classes[index];
        BOOL result = [currentClass isMineTwitterResponseError:error];
        
        if (result) {
            resultClass = currentClass;
            break;
        }
    }
    
    if (!resultClass)
        resultClass = [self class];
    
    JFFTwitterResponseError *result = [resultClass new];
    
    if (result) {
        
        result.context  = context;
        result.response = jsonObject;
    }
    
    return result;
}

@end
