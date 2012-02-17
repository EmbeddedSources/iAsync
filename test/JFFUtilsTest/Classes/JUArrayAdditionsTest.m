@interface JUArrayAdditionsTest : GHTestCase
@end

@implementation JUArrayAdditionsTest

-(void)testIsEqualVersionWorksCorrectly
{
   NSArray* items_    = nil;
   NSArray* received_ = nil;
   NSArray* expected_ = nil;
   
   
   {
      items_ = [ NSArray arrayWithObjects: 
                  @"abra"
                , @"shwabra"
                , @"kadabra"
                , @"abra"
                , @"habra"
                , @"kadabra"
                , @"ABra"
                , nil ];
                
      
      received_ = [ items_ unique ];
      expected_ = [ NSArray arrayWithObjects: 
                     @"abra"
                   , @"shwabra"
                   , @"kadabra"
                   , @"habra"
                   , @"ABra"
                   , nil ];

      GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
   }
   
   {
      items_ = [ NSArray arrayWithObjects: 
                  @"one"
                , @"two"
                , @"three"
                , @"two"
                , @"one"
                , @"four"
                , @"five"
                , @"one"
                , nil ];
      
      received_ = [ items_ unique ];
      expected_ = [ NSArray arrayWithObjects: 
                     @"one"
                   , @"two"
                   , @"three"
                   , @"four"
                   , @"five"
                   , nil ];      
      
      GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
   }   
}

-(void)testIsEqualVersionWorksWithEmptyArray
{
   NSArray* items_    = nil;
   NSArray* received_ = nil;
   NSArray* expected_ = nil;

   {
      items_ = [ NSArray array ];
      
      received_ = [ items_ unique ];
      expected_ = items_;
      
      GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
   }
}


-(void)testBlockVersionWorksCorrectly
{
   NSArray* items_    = nil;
   NSArray* received_ = nil;
   NSArray* expected_ = nil;
   
   EqualityCheckerBlock predicate_ = ^( id left_, id right_ )
   {
      NSComparisonResult result1_ = [ left_  caseInsensitiveCompare: right_ ];
      NSComparisonResult result2_ = [ right_ caseInsensitiveCompare: left_  ];
      
      BOOL result_equal_ = ( result1_      == result2_ );
      BOOL result_same_  = ( NSOrderedSame == result2_ );
      
      return (BOOL)( result_same_ && result_equal_ );
   };
   
   {
      items_ = [ NSArray arrayWithObjects: 
                  @"abra"
                , @"shwabra"
                , @"kadabra"
                , @"abRa"
                , @"habra"
                , @"KAdabRA"
                , @"ABra"
                , nil ];
      
      
      
      received_ = [ items_ uniqueBy: predicate_ ];
      expected_ = [ NSArray arrayWithObjects: 
                   @"abra"
                   , @"shwabra"
                   , @"kadabra"
                   , @"habra"
                   , nil ];
      
      GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
   }
   
   {
      items_ = [ NSArray arrayWithObjects: 
                  @"one"
                , @"Two"
                , @"THREE"
                , @"two"
                , @"One"
                , @"four"
                , @"five"
                , @"ONE"
                , nil ];
      
      
      received_ = [ items_ uniqueBy: predicate_ ];
      expected_ = [ NSArray arrayWithObjects: 
                     @"one"
                   , @"Two"
                   , @"THREE"
                   , @"four"
                   , @"five"
                   , nil ];      
      
      GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
   }   
}


@end
