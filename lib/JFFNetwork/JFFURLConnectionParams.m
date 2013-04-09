#import "JFFURLConnectionParams.h"

@implementation JFFURLConnectionParams

- (id)copyWithZone:(NSZone *)zone
{
    JFFURLConnectionParams *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_url                 = [ self->_url      copyWithZone: zone];
        copy->_httpBody            = [ self->_httpBody copyWithZone: zone];
        copy->_httpMethod          = [ self->_httpMethod copyWithZone: zone ];
        copy->_headers             = [ self->_headers  copyWithZone: zone];

        // TODO : Make a deep copy of the stream
        // @adk : Plain assignment pay lead to inproper resource management and inconsistency
        copy->_httpBodyStream      = _httpBodyStream;
        
        
        copy->_useLiveConnection   = _useLiveConnection;
        copy->_certificateCallback = [ _certificateCallback copy ];
        
        //cookie storage is common object for different connections
        //do not copy it
        copy->_cookiesStorage      = _cookiesStorage;
    }
    
    return copy;
}

- (NSString *)description
{
    static NSString *format = @"<JFFURLConnectionParams url:%@, httpBody:%@, headers:%@, useLiveConnection:%d>";
    return [[NSString alloc] initWithFormat:format, _url, [_httpBody toString], _headers, _useLiveConnection];
}

@end
