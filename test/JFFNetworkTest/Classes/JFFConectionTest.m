@interface JFFConectionTest : GHAsyncTestCase

@end

@implementation JFFConectionTest

//JTODO add file - http://10.28.9.57:9000/about/
-(void)RtestValidDownloadCompletesCorrectly
{
    [ self prepare ];

    NSURL* data_url_ = [ NSURL URLWithString: @"http://10.28.9.57:9000/about/" ];

    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url = data_url_;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];
   
    id< JNUrlConnection > connection_ = [ factory_ createFastConnection ];
    NSMutableData* totalData_ = [ NSMutableData data ];
    NSData* expectedData_ = [ NSData dataWithContentsOfURL: data_url_ ];

    connection_.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^( NSData* dataChunk_ )
    {
        [ totalData_ appendData: dataChunk_ ];
    };

    connection_.didFinishLoadingBlock = ^( NSError* error_ )
    {
        GHAssertNil( error_, @"Unexpected error - %@", error_ );    
        GHAssertTrue( [ expectedData_ length ] == [ totalData_ length ], @"packet mismatch" );
        [ self notify: kGHUnitWaitStatusSuccess 
          forSelector: _cmd ];
    };
  
    [ connection_ start ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}

//now http://kdjsfhjkfhsdfjkdhfjkds.com redirected
-(void)RtestInValidDownloadCompletesWithError
{
    [ self prepare ];

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];

    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url = dataUrl_;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];

    id< JNUrlConnection > connection_ = [ factory_ createFastConnection ];

    connection_.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^( NSData* dataChunk_ )
    {
    };
    connection_.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( nil != error_ )
        {
            [ self notify: kGHUnitWaitStatusSuccess 
              forSelector: _cmd ];
            return;
        }

        [ self notify: kGHUnitWaitStatusFailure
          forSelector: _cmd ];
    };

    [ connection_ start ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}


@end
