
@interface NSConnectionTest : GHAsyncTestCase
@end

@implementation NSConnectionTest

-(void)setUp
{
    [ JNNsUrlConnection enableInstancesCounting ];
}

-(void)testValidDownloadCompletesLocalFileCorrectly
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

        NSMutableData* totalData_ = [ NSMutableData new ];
        NSData* expectedData_ = [ [ NSData alloc ] initWithContentsOfURL: dataUrl_ ];

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

-(void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount_ = [ JNNsUrlConnection instancesCount ];
    __block BOOL dataReceived_ = NO;

    @autoreleasepool
    {
        [self prepare];

        NSURL* dataUrl_ = [ [ NSURL alloc ] initWithString: @"http://www.google.com" ];

        JFFURLConnectionParams *params = [JFFURLConnectionParams new];
        params.url = dataUrl_;
        JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
        
        id< JNUrlConnection > connection = [factory createStandardConnection];
        
        connection.didReceiveResponseBlock = ^(id response) {
            //IDLE
        };
        
        connection.didReceiveDataBlock = ^(NSData *dataChunk) {
            dataReceived_ = YES;
        };
        
        connection.didFinishLoadingBlock = ^(NSError *error) {
            if (nil != error) {
                [self notify:kGHUnitWaitStatusFailure
                 forSelector:_cmd];
                return;
            }
            
            [self notify:kGHUnitWaitStatusSuccess
             forSelector:_cmd];
        };
        
        [connection start];
        [self waitForStatus:kGHUnitWaitStatusSuccess
                    timeout:61.];
    }
    
    GHAssertTrue( dataReceived_, @"packet mismatch" );
    
    NSUInteger currentCount = [JNNsUrlConnection instancesCount];
    GHAssertTrue(initialCount_ == currentCount, @"packet mismatch");
}

-(void)RtestInValidDownloadCompletesWithError
{
    [self prepare];
    
    NSURL *dataUrl = [NSURL URLWithString:@"http://kdjsfhjkfhsdfjkdhfjkds.com"];
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url = dataUrl;
    JNConnectionsFactory *factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams:params];
    
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
