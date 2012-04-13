@interface NSConnectionTest : GHAsyncTestCase

@end


@implementation NSConnectionTest

-(void)testValidDownloadCompletesCorrectly
{
    [ self prepare ];

    NSURL* data_url_ = [ [ JNTestBundleManager decodersDataBundle ] URLForResource: @"1" 
                                                                     withExtension: @"txt" ];

    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url = data_url_;
    JNConnectionsFactory* factory_ = [ [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ] autorelease ];

    id< JNUrlConnection > connection_ = [ factory_ createStandardConnection ];
    NSMutableData* total_data_ = [ NSMutableData data ];
    NSData* expected_data_ = [ NSData dataWithContentsOfURL: data_url_ ];

    connection_.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
    {
        [ total_data_ appendData: data_chunk_ ];
    };

    connection_.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( nil != error_ )
        {
            [ self notify: kGHUnitWaitStatusFailure
              forSelector: _cmd ];
            return;
        }

        GHAssertTrue( [ expected_data_ isEqualToData: total_data_ ], @"packet mismatch" );
        [ self notify: kGHUnitWaitStatusSuccess 
          forSelector: _cmd ];
    };

    [ connection_ start ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}

-(void)RtestInValidDownloadCompletesWithError
{
    [ self prepare ];

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];

    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url = dataUrl_;
    JNConnectionsFactory* factory_ = [ [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ] autorelease ];

    id< JNUrlConnection > connection_ = [ factory_ createStandardConnection ];
   
    connection_.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
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
