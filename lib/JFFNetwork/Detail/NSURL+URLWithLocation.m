#import "NSURL+URLWithLocation.h"

static NSString *portComponentStr(NSNumber *port)
{
    static NSString *const urlPortFormat = @":%@";
    
    return port ? [[NSString alloc] initWithFormat:urlPortFormat, port] : @"";
}

static NSString *loginAndPasswordComponentStr(NSString *login, NSString *password)
{
    if (![login hasSymbols])
        return @"";
    
    if (![password hasSymbols]) {
        static NSString *const urlLoginFormat = @"%@@";
        return [[NSString alloc] initWithFormat:urlLoginFormat, login];
    }
    
    static NSString *const urlLoginPasswordFormat = @"%@:%@@";
    return [[NSString alloc] initWithFormat:urlLoginPasswordFormat, login, password];
}

@implementation NSURL (URLWithLocation)

- (id)URLWithLocation:(NSString *)location
{
    NSParameterAssert([location hasPrefix:@"/"]);
    
    static NSString *const urlFormat = @"%@://%@%@%@%@";
    NSString *urlString = [[NSString alloc] initWithFormat:urlFormat,
                           self.scheme,
                           loginAndPasswordComponentStr(self.user, self.password),
                           self.host,
                           portComponentStr( self.port ),
                           location
                           ];
    
    NSURL *result = [urlString toURL];
    
    return result;
}

@end
