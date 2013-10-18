#import "NSError+JSON.h"

@implementation NSError (JSON)

- (NSString *)toJson
{
    return [NSString stringWithFormat: @"{ \"error\" : \"%@\", \"domain\" : \"%@\", \"code\" : \"%d\", \"localizedDescription\" : \"%@\" }", NSStringFromClass([self class]), self.domain, self.code, self.localizedDescription];
}

@end
