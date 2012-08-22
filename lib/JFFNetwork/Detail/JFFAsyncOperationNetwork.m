#import "JFFAsyncOperationNetwork.h"

#import "JFFURLConnectionParams.h"
#import "JNConnectionsFactory.h"
#import "JNUrlConnection.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFAsyncOperationNetwork

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    {
        JNConnectionsFactory* factory_ =
        [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: self.params ];

        self.connection = self.params.useLiveConnection
            ? [ factory_ createFastConnection     ]
            : [ factory_ createStandardConnection ];
    }

    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;

    __unsafe_unretained JFFAsyncOperationNetwork* self_ = self;

    progress_ = [ progress_ copy ];
    self.connection.didReceiveDataBlock = ^( NSData* data_ )
    {
        if ( progress_ )
            progress_( data_ );
    };

    handler_ = [ handler_ copy ];
    self.connection.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( handler_ )
            handler_( error_ ? nil : self_.resultContext, error_ );
    };

    self.connection.didReceiveResponseBlock = ^void( id< JNUrlResponse > response_ )
    {
        self_.resultContext = response_;
    };

    [ self.connection start ];
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
