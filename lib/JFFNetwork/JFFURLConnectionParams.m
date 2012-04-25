#import "JFFURLConnectionParams.h"

@implementation JFFURLConnectionParams

@synthesize url                 = _url;
@synthesize httpBody            = _httpBody;
@synthesize httpMethod          = _httpMethod;
@synthesize headers             = _headers;
@synthesize useLiveConnection   = _useLiveConnection; 
@synthesize certificateCallback = _certificateCallback;
@synthesize cookiesStorage      = _cookiesStorage;

@end
