@interface JFFConectionTest : GHAsyncTestCase

@end

@implementation JFFConectionTest

//TODO test leaks

-(void)setUp
{
    [ JFFURLConnection enableInstancesCounting ];//JTODO test
}

//http://jigsaw.w3.org/HTTP/300/Go_301
-(void)testRedirectOnHttp301Code
{
    NSUInteger initialInstancesCount_ = [ JFFURLConnection instancesCount ];

    [ self prepare ];

    __block NSError* didFinishLoadingBlockError_;

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://jigsaw.w3.org/HTTP/300/301.html" ];
    NSData* expectedData_ = [ [ NSData alloc ] initWithContentsOfURL: dataUrl_ ];

    NSMutableData* totalData_ = [ NSMutableData new ];

    @autoreleasepool
    {
        
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
            [ totalData_ appendData: dataChunk_ ];
        };
        
        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            didFinishLoadingBlockError_ = error_;
            [ self notify: kGHUnitWaitStatusSuccess
              forSelector: _cmd ];
        };
        
        [ connection_ start ];
        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 61. ];
    }
    
    GHAssertNil( didFinishLoadingBlockError_, @"Unexpected error - %@", didFinishLoadingBlockError_ );
    GHAssertTrue( [ expectedData_ length ] == [ totalData_ length ], @"packet mismatch" );
    
    GHAssertTrue( initialInstancesCount_ == [ JFFURLConnection instancesCount ], @"packet mismatch" );
}

// http://jigsaw.w3.org/HTTP/300/Overview.html
-(void)testRedirectOnHttp302Code
{
    NSUInteger initialInstancesCount_ = [ JFFURLConnection instancesCount ];

    [ self prepare ];

    __block NSError* didFinishLoadingBlockError_;

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://jigsaw.w3.org/HTTP/300/302.html" ];
    NSData* expectedData_ = [ [ NSData alloc ] initWithContentsOfURL: dataUrl_ ];

    NSMutableData* totalData_ = [ NSMutableData new ];

    @autoreleasepool
    {

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
            [ totalData_ appendData: dataChunk_ ];
        };

        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            didFinishLoadingBlockError_ = error_;
            [ self notify: kGHUnitWaitStatusSuccess
              forSelector: _cmd ];
        };

        [ connection_ start ];
        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 61. ];
    }

    GHAssertNil( didFinishLoadingBlockError_, @"Unexpected error - %@", didFinishLoadingBlockError_ );
    GHAssertTrue( [ expectedData_ length ] == [ totalData_ length ], @"packet mismatch" );

    GHAssertTrue( initialInstancesCount_ == [ JFFURLConnection instancesCount ], @"packet mismatch" );
}

//JTODO add file - http://10.28.9.57:9000/about/
-(void)RtestValidDownloadCompletesCorrectly
{
    [ self prepare ];

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://10.28.9.57:9000/about/" ];

    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url = dataUrl_;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];
   
    id< JNUrlConnection > connection_ = [ factory_ createFastConnection ];
    NSMutableData* totalData_ = [ NSMutableData new ];
    NSData* expectedData_ = [ NSData dataWithContentsOfURL: dataUrl_ ];

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
