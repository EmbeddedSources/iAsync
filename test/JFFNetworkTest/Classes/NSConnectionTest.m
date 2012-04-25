
@interface NSConnectionTest : GHAsyncTestCase
@end

@implementation NSConnectionTest

-(void)setUp
{
    [ JNNsUrlConnection enableInstancesCounting ];
}

-(void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount_ = [ JNNsUrlConnection instancesCount ];

    @autoreleasepool
    {
        [ self prepare ];

        NSURL* dataUrl_ = [ [ JNTestBundleManager decodersDataBundle ] URLForResource: @"1" 
                                                                        withExtension: @"txt" ];

        JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
        params_.url = dataUrl_;
        JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];

        id< JNUrlConnection > connection_ = [ factory_ createStandardConnection ];

        NSUInteger currentCount_ = [ JNNsUrlConnection instancesCount ];
        GHAssertTrue( currentCount_ > initialCount_, @"packet mismatch" );

        NSMutableData* totalData_ = [ NSMutableData data ];
        NSData* expectedData_ = [ NSData dataWithContentsOfURL: dataUrl_ ];

        connection_.didReceiveResponseBlock = ^( id response_ )
        {
            //IDLE
        };
        connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
        {
            [ totalData_ appendData: data_chunk_ ];
        };

        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            if ( nil != error_ )
            {
                [ self notify: kGHUnitWaitStatusFailure
                  forSelector: _cmd ];
                return;
            }

            GHAssertTrue( [ expectedData_ isEqualToData: totalData_ ], @"packet mismatch" );
            [ self notify: kGHUnitWaitStatusSuccess 
              forSelector: _cmd ];
        };

        [ connection_ start ];
        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 61. ];
    }

    NSUInteger currentCount_ = [ JNNsUrlConnection instancesCount ];
    GHAssertTrue( initialCount_ == currentCount_, @"packet mismatch" );
}

-(void)RtestInValidDownloadCompletesWithError
{
    [ self prepare ];

    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];

    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url = dataUrl_;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];

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
