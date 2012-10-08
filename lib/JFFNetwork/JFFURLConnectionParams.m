#import "JFFURLConnectionParams.h"

@implementation JFFURLConnectionParams

- (id)copyWithZone:(NSZone *)zone
{
    JFFURLConnectionParams *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_url                 = [self->_url      copyWithZone:zone];
        copy->_httpBody            = [self->_httpBody copyWithZone:zone];
        copy->_headers             = [self->_headers  copyWithZone:zone];
        copy->_useLiveConnection   = self->_useLiveConnection;
        copy->_certificateCallback = self->_certificateCallback;
        
        //cookie storage is common object for different connections
        //do not copy it
        copy->_cookiesStorage      = self->_cookiesStorage;
    }
    
    return copy;
}

- (NSString *)description
{
    static NSString *format = @"<JFFURLConnectionParams url:%@, httpBody:%@, headers:%@, useLiveConnection:%d>";
    return [[NSString alloc] initWithFormat:format, _url, [_httpBody toString], _headers, _useLiveConnection];
}

@end
