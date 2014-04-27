#import "JFFNetworkUploadProgressCallback.h"

#import "JFFURLConnectionParams.h"

@implementation JFFNetworkUploadProgressCallback

- (NSNumber *)progress
{
    return _progress;
}

- (NSURL *)url
{
    return _params.url;
}

- (NSDictionary *)headers
{
    return _params.headers;
}

@end
