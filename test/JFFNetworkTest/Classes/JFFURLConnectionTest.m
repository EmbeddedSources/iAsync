
@interface JFFURLConnectionTest : GHAsyncTestCase
@end

@implementation JFFURLConnectionTest

-(void)setUp
{
    [ JFFURLConnection       enableInstancesCounting ];
    [ JFFURLConnectionParams enableInstancesCounting ];
}

-(void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount_       = [ JFFURLConnection instancesCount ];

    __weak id< JNUrlConnection > wealConnection_ = nil;
    @autoreleasepool
    {
        @autoreleasepool
        {
            [ self prepare ];

            NSURL* dataUrl_ = [ NSURL URLWithString: @"http://vkusnoe.info/uploads/taginator/Feb-2012/test.jpg" ];

            JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
            params_.url = dataUrl_;
            JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];

            NSObject< JNUrlConnection >* connection_ = [ factory_ createFastConnection ];

            NSUInteger currentCount_ = [ JFFURLConnection instancesCount ];

            currentCount_ = [ JFFURLConnectionParams instancesCount ];

            NSMutableData* totalData_ = [ NSMutableData data ];
            NSData* expectedData_ = [ NSData dataWithContentsOfURL: dataUrl_ ];

            wealConnection_ = connection_;
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
        }
        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 61. ];
    }

    GHAssertTrue( wealConnection_ == nil, @"OK" );

    NSUInteger currentCount_ = [ JFFURLConnection instancesCount ];
    GHAssertTrue( initialCount_ == currentCount_, @"packet mismatch" );

    NSUInteger currentParamsCount_ = [ JFFURLConnectionParams instancesCount ];
    GHAssertTrue( initialCount_ == currentParamsCount_, @"packet mismatch" );
}

@end
