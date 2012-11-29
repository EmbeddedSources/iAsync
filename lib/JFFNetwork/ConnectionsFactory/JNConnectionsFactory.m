#import "JNConnectionsFactory.h"

#import "JFFURLConnection.h"
#import "JNNsUrlConnection.h"
#import "JFFURLConnectionParams.h"

@implementation JNConnectionsFactory
{
    JFFURLConnectionParams* _params;
}

#pragma mark -
#pragma mark Constructor
-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

- (id)initWithURLConnectionParams:(JFFURLConnectionParams *)params
{
    NSParameterAssert(params.url);

    self = [ super init ];

    if (self) {
        self->_params = params;
    }

    return self;
}

#pragma mark -
#pragma mark Factory
-(id< JNUrlConnection >)createFastConnection
{
    return [ [ JFFURLConnection alloc] initWithURLConnectionParams: self->_params ];
}

-(id< JNUrlConnection >)createStandardConnection
{
    return [ [ JNNsUrlConnection alloc ] initWithURLConnectionParams: self->_params ];
}

@end
