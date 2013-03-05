
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
    const NSUInteger initialCount_ = [ JFFURLConnection instancesCount ];

    __weak id< JNUrlConnection > wealConnection_ = nil;
    @autoreleasepool
    {
        @autoreleasepool
        {
            NSURL* dataUrl_ = [ NSURL URLWithString: @"http://www.ietf.org/rfc/rfc4180.txt" ];

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
                NSLog( @"[JFFURLConnectionTest] didReceiveResponseBlock: %@ ", response_ );
            };
            connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
            {
                NSLog( @"[JFFURLConnectionTest] didReceiveDataBlock: %d ", [ data_chunk_ length ] );
                [ totalData_ appendData: data_chunk_ ];
            };

            
            TestAsyncRequestBlock starterBlock_ = ^void( JFFSimpleBlock stopTest_ )
            {
                connection_.didFinishLoadingBlock = ^( NSError* error_ )
                {
                    NSLog( @"[JFFURLConnectionTest] didFinishLoadingBlock: %@ ", error_ );
                    
                    stopTest_();
                    GHAssertTrue( [ expectedData_ isEqualToData: totalData_ ], @"packet mismatch" );
                };
                
                [ connection_ start ];
                
            };
            
            [ self performAsyncRequestOnMainThreadWithBlock: starterBlock_
                                                   selector: _cmd
                                                    timeout: 61.0 ];
        }
    }

    GHAssertTrue( wealConnection_ == nil, @"OK" );

    NSUInteger currentCount_ = [ JFFURLConnection instancesCount ];
    GHAssertTrue( initialCount_ == currentCount_, @"packet mismatch" );

    NSUInteger currentParamsCount_ = [ JFFURLConnectionParams instancesCount ];
    GHAssertTrue( initialCount_ == currentParamsCount_, @"packet mismatch" );
}

@end
