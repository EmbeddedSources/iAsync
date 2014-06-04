#import "JFFNetworkUploadProgressCallback.h"

#import "JFFURLConnectionParams.h"

@implementation JFFNetworkUploadProgressCallback

- (NSURL *)url
{
    return _params.url;
}

- (NSDictionary *)headers
{
    return _params.headers;
}

@end
