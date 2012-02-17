#import <JFFUtils/JFFMutableAssignDictionary.h>

@interface JFFMutableAssignDictionaryTest : GHTestCase
@end

@implementation JFFMutableAssignDictionaryTest

-(void)testMutableAssignDictionaryAssignIssue
{
   NSObject* target_ = [ NSObject new ];

   __block BOOL target_deallocated_ = NO;
   [ target_ addOnDeallocBlock: ^void( void )
   {
      target_deallocated_ = YES;
   } ];

   JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];
   [ dict_ setObject: target_ forKey: @"1" ];

   GHAssertTrue( 1 == [ dict_ count ], @"Contains 1 object" );

   [ target_ release ];

   GHAssertTrue( target_deallocated_, @"Target should be dealloced" );
   GHAssertTrue( 0 == [ dict_ count ], @"Empty array" );

   [ dict_ release ];
}

-(void)testMutableAssignDictionaryFirstRelease
{
   JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

   __block BOOL dict_deallocated_ = NO;
   [ dict_ addOnDeallocBlock: ^void( void )
   {
      dict_deallocated_ = YES;
   } ];

   NSObject* target_ = [ NSObject new ];
   [ dict_ setObject: target_ forKey: @"1" ];

   [ dict_ release ];

   GHAssertTrue( dict_deallocated_, @"Target should be dealloced" );

   [ target_ release ];
}

-(void)testObjectForKey
{
   JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

   __block BOOL target_deallocated_ = NO;
   @autoreleasepool
   {
      NSObject* object_ = [ NSObject new ];

      [ object_ addOnDeallocBlock: ^void( void )
      {
         target_deallocated_ = YES;
      } ];

      [ dict_ setObject: object_ forKey: @"1" ];

      GHAssertTrue( [ dict_ objectForKey: @"1" ] == object_, @"Dict contains object_" );
      GHAssertTrue( [ dict_ objectForKey: @"2" ] == nil, @"Dict no contains object for key \"2\"" );

      [ object_ release ];
   }

   GHAssertTrue( target_deallocated_, @"Target should be dealloced" );

   GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );

   [ dict_ release ];
}

-(void)testReplaceObjectInDict
{
   JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

   @autoreleasepool
   {
      __block BOOL replaced_object_dealloced_ = NO;
      NSObject* object_ = nil;

      @autoreleasepool
      {
         NSObject* replaced_object_ = [ NSObject new ];
         [ replaced_object_ addOnDeallocBlock: ^void()
         {
            replaced_object_dealloced_ = YES;
         } ];

         object_ = [ NSObject new ];

         [ dict_ setObject: replaced_object_ forKey: @"1" ];

         GHAssertTrue( [ dict_ objectForKey: @"1" ] == replaced_object_, @"Dict contains object_" );
         GHAssertTrue( [ dict_ objectForKey: @"2" ] == nil, @"Dict no contains object for key \"2\"" );

         [ dict_ setObject: object_ forKey: @"1" ];
         GHAssertTrue( [ dict_ objectForKey: @"1" ] == object_, @"Dict contains object_" );

         [ replaced_object_ release ];
      }

      GHAssertTrue( replaced_object_dealloced_, @"OK" );

      NSObject* current_object_ = [ dict_ objectForKey: @"1" ];
      GHAssertTrue( current_object_ == object_, @"OK" );

      [ object_ release ];
   }

   GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );

   [ dict_ release ];
}

@end
