#import "JFFNetworkUploadProgressCallback.h"
#import "JFFURLConnectionParams.h"

@implementation JFFNetworkUploadProgressCallback

-(NSNumber*)progress
{
    return self->_progress;
}

-(NSURL*)url
{
    return self->_params.url;
}

-(NSDictionary*)headers
{
    return self->_params.headers;
}

@end
