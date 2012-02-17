#import "JMStringHolder.h"

#import "JMParent.h"
#import "JMChild.h"

#import <JFFUtils/JFFCastFunctions.hpp>

@interface ObjCppCastingTest : GHTestCase
@end


@implementation ObjCppCastingTest

-(void)testNilIsCastedToNil
{
   NSString* result_ = nil;

   {
      result_ = objc_kind_of_cast<NSString>( nil );
      GHAssertNil( result_, @"nil expected" );
   }
   
   {
      result_ = objc_member_of_cast<NSString>( nil );
      GHAssertNil( result_, @"nil expected" );
   }
}

-(void)testStringToArrayCastReturnsNil
{
   NSString* christmas_cheer_ = @"Merry Christmas";
   NSArray* result_ = nil;
   
   {
      result_ = objc_kind_of_cast<NSArray>( christmas_cheer_ );
      GHAssertNil( result_, @"nil expected" );
   }
   
   {
      result_ = objc_member_of_cast<NSArray>( christmas_cheer_ );
      GHAssertNil( result_, @"nil expected" );
   }
}

-(void)testStringToStringCastReturnsValidObject
{
   {
      id christmas_cheer_ = @"Merry Christmas";
      NSString* result_ = objc_kind_of_cast<NSString>( christmas_cheer_ );
      GHAssertNotNil( result_, @"unexpected nil object" );
      
      GHAssertTrue( [ christmas_cheer_ isEqual: result_ ], @"A cast has changed an object" );
   }

   {
      JMStringHolder* result_ = nil;
      JMStringHolder* christmas_cheer_ = [ [ JMStringHolder new ] autorelease ];
      christmas_cheer_.content = @"Merry Christmas";

      result_ = objc_member_of_cast<JMStringHolder>( christmas_cheer_ );
      GHAssertNotNil( result_, @"unexpected nil object" );
      GHAssertTrue( [ christmas_cheer_.content isEqualToString: result_.content ], @"A cast has changed an object" );      
   }
}

-(void)testKindOfCastToSuperTypeReturnsSameObject
{
   JMStringHolder* christmas_cheer_ = [ [ JMStringHolder new ] autorelease ];
   christmas_cheer_.content = @"Merry Christmas";
   
   id result_ = nil;

   {
      result_ = objc_kind_of_cast<NSObject>( christmas_cheer_ );
      GHAssertTrue( christmas_cheer_ == result_, @"same object expected" );
   }   
}

@end
