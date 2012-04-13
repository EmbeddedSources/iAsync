
@interface JNLiveLoaderTest : GHAsyncTestCase
@end

@implementation JNLiveLoaderTest

//JTODO fix test ( add file )
-(void)TtestValidBlockDownloadCompletesCorrectly
{  
   //Our build server
    NSURL* data_url_ = [ NSURL URLWithString: @"http://10.28.9.57:9000/about/" ];
    NSData* expected_data_ = [ NSData dataWithContentsOfURL: data_url_ ];

    JFFAsyncOperation loader_ = liveDataURLResponseLoader( data_url_, nil, nil );

    loader_( nil, nil, ^void( id result_, NSError* error_ ) 
    {
        GHAssertNil ( error_, @"Unexpected error : %@", error_ );
        GHAssertTrue( [ expected_data_ length ] == [ result_ length ], @"packet mismatch" );
    } );

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}

//now redirected
-(void)RtestInvalidBlockDownloadCompletesWithError
{
    NSURL* dataUrl_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];
    JFFAsyncOperation loader_ = liveDataURLResponseLoader( dataUrl_, nil, nil );
   
    loader_( nil, nil, ^void( id result_, NSError* error_ ) 
    {
        GHAssertNotNil( error_, @"Unexpected nil error" );
    } );

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}

@end
