#import "JFFAsyncOperationNetwork.h"

#import "JFFURLConnectionParams.h"
#import "JNConnectionsFactory.h"
#import "JNUrlConnection.h"
#import "JHttpFlagChecker.h"
#import "JHttpError.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFAsyncOperationNetwork

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    {
        JNConnectionsFactory* factory_ =
        [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: self.params ];

        self.connection = [ factory_ createConnection ];
    }

    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;

    __weak JFFAsyncOperationNetwork* self_ = self;

    progress_ = [ progress_ copy ];
    self.connection.didReceiveDataBlock = ^( NSData* data_ )
    {
        if ( progress_ )
            progress_( data_ );
    };

    handler_ = [ handler_ copy ];
    JFFDidFinishLoadingHandler finish_ = ^( NSError* error_ )
    {
        if ( handler_ )
            handler_( error_ ? nil : self_.resultContext, error_ );
    };
    
    finish_ = [ finish_ copy ];
    self.connection.didFinishLoadingBlock = finish_;

    
    self.connection.didReceiveResponseBlock = ^void( id< JNUrlResponse > response_ )
    {
        self_.resultContext = response_;
        
        NSInteger statusCode_ = [ response_ statusCode ];
        
        if ( [ JHttpFlagChecker isDownloadErrorFlag : statusCode_ ] )
        {
            JHttpError* httpError_ = [ [ JHttpError alloc ] initWithHttpCode: statusCode_ ];
            finish_( httpError_ );

            [ self_ forceCancel ];
        }
    };

    [ self.connection start ];
}

-(void)forceCancel
{
    [ self cancel: YES ];
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
