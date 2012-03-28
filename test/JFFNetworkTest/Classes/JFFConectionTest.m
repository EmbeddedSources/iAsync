@interface JFFConectionTest : GHAsyncTestCase

@end

@implementation JFFConectionTest

//now not used
-(void)TtestValidDownloadCompletesCorrectly
{
    [ self prepare ];

    NSURL* data_url_ = [ NSURL URLWithString: @"http://10.28.9.57:9000/about/" ];

    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: data_url_
                                                                         httpBody: nil
                                                                          headers: nil ];
    [ factory_ autorelease ];
   
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

//now not used
-(void)RtestInValidDownloadCompletesWithError
{
    [ self prepare ];

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];

    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: dataUrl_
                                                                         httpBody: nil
                                                                          headers: nil ];
    [ factory_ autorelease ];

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
