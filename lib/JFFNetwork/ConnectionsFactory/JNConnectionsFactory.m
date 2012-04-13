#import "JNConnectionsFactory.h"

#import "JFFURLConnection.h"
#import "JNNsUrlConnection.h"
#import "JFFURLConnectionParams.h"

@interface JNConnectionsFactory ()

@property ( nonatomic, retain ) JFFURLConnectionParams* params;

@end

@implementation JNConnectionsFactory

@synthesize params = _params;

-(void)dealloc
{
    [ _params release ];

    [ super dealloc ];
}

#pragma mark -
#pragma mark Constructor
-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    [ self release ];   
    return nil;
}

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_
{
    if ( nil == params_.url )
    {
        NSParameterAssert( params_.url );
        [ self release ];

        return nil;
    }

    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }

    self.params = params_;

    return self;
}

#pragma mark -
#pragma mark Factory
-(id< JNUrlConnection >)createFastConnection
{
    id result_ = [ [ JFFURLConnection alloc] initWithURLConnectionParams: self.params ];
    return [ result_ autorelease ];
}

-(id< JNUrlConnection >)createStandardConnection
{
    id result_ = [ [ JNNsUrlConnection alloc ] initWithURLConnectionParams: self.params ];
    return [ result_ autorelease ];
}

@end
