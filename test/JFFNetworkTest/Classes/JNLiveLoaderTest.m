@interface JNLiveLoaderTest : GHTestCase

@end


@implementation JNLiveLoaderTest


-(void)testValidBlockDownloadCompletesCorrectly
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
}


-(void)testInvalidBlockDownloadCompletesWithError
{
   NSURL* data_url_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];
   JFFAsyncOperation loader_ = liveDataURLResponseLoader( data_url_, nil, nil );
   
   loader_( nil, nil, ^void( id result_, NSError* error_ ) 
   {
      GHAssertNotNil ( error_, @"Unexpected nil error" );
   } );
}

@end
