#import "NSError+JSON.h"

@implementation NSError (JSON)

- (NSString *)toJson
{
    NSNumber* errorCode = @(self.code);
    NSString* errorCodeString = [ errorCode descriptionWithLocale: nil ];
    
    return [NSString stringWithFormat: @"{ \"error\" : \"%@\", \"domain\" : \"%@\", \"code\" : \"%@\", \"localizedDescription\" : \"%@\" }", NSStringFromClass([self class]), self.domain, errorCodeString, self.localizedDescription];
}

@end
