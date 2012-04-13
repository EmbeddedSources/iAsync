#import "JFFAsyncOperationNetwork.h"

#import "JFFURLConnectionParams.h"
#import "JNUrlConnection.h"
#import "JNConnectionsFactory.h"

@implementation JFFAsyncOperationNetwork

@synthesize params        = _params;
@synthesize connection    = _connection;
@synthesize resultContext = _resultContext;

-(void)dealloc
{
    [ _params        release ];
    [ _connection    release ];
    [ _resultContext release ];

    [ super dealloc ];
}

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    {
        JNConnectionsFactory* factory_ =
        [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: self.params ];

        self.connection = self.params.useLiveConnection
            ? [ factory_ createFastConnection     ]
            : [ factory_ createStandardConnection ];

        [ factory_ release ];
    }

    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;

    [ self.connection start ];

    __unsafe_unretained typeof(self) self_ = self;

    progress_ = [ [ progress_ copy ] autorelease ];
    self.connection.didReceiveDataBlock = ^( NSData* data_ )
    {
        if ( progress_ )
            progress_( data_ );
    };

    handler_ = [ [ handler_ copy ] autorelease ];
    self.connection.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( handler_ )
            handler_( error_ ? nil : self_.resultContext, error_ );
    };

    self.connection.didReceiveResponseBlock = ^void( id< JNUrlResponse > response_ )
    {
        self_.resultContext = response_;
    };
}

-(void)cancel:( BOOL )canceled_
{
    if ( canceled_ )
    {
        [ self.connection cancel ];
        self.connection = nil;
    }
}

@end
