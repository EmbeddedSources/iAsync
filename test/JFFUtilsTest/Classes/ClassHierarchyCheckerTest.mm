#import "JMParent.h"
#import "JMChild.h"

#import <JFFUtils/JFFCastFunctions.hpp>

@interface ClassHierarchyCheckerTest : GHTestCase
@end


@implementation ClassHierarchyCheckerTest


-(void)testClassCheckerRecognizesHierarchy
{  
    {
        GHAssertTrue( class_srcIsSuperclassOfDest   ( [ JMParent class], [ JMChild class ] ), @"Valid hierarchy not recognized" );
        GHAssertTrue( class_isClassesInSameHierarchy( [ JMParent class], [ JMChild class ] ), @"Valid hierarchy not recognized" );
    }
   
   {
      GHAssertFalse( class_srcIsSuperclassOfDest   ( [ JMChild class], [ JMParent class ] ), @"Valid hierarchy not recognized" );
      GHAssertTrue ( class_isClassesInSameHierarchy( [ JMChild class], [ JMParent class ] ), @"Valid hierarchy not recognized" );
   }   
   
   {
      GHAssertFalse( class_srcIsSuperclassOfDest   ( [ JMChild class], [ NSObject class ] ), @"Valid deep hierarchy not recognized" );
      GHAssertTrue ( class_isClassesInSameHierarchy( [ JMChild class], [ NSObject class ] ), @"Valid deep hierarchy not recognized" );
   }   
}

-(void)testClassCheckerRegectsAlienClass
{
   GHAssertFalse( class_srcIsSuperclassOfDest   ( [ JMChild class], [ NSString class ] ), @"Valid hierarchy not recognized" );
   GHAssertFalse( class_isClassesInSameHierarchy( [ JMChild class], [ NSString class ] ), @"Valid hierarchy not recognized" );
}

-(void)testClassCheckerRejectsSingleNil
{
   {
      GHAssertFalse( class_srcIsSuperclassOfDest   ( Nil, [ NSString class ] ), @"Valid hierarchy not recognized" );
      GHAssertFalse( class_isClassesInSameHierarchy( Nil, [ NSString class ] ), @"Valid hierarchy not recognized" );
   }

   {
      GHAssertFalse( class_srcIsSuperclassOfDest   ( [ NSString class ], Nil ), @"Valid hierarchy not recognized" );
      GHAssertFalse( class_isClassesInSameHierarchy( [ NSString class ], Nil ), @"Valid hierarchy not recognized" );
   }
}

-(void)testClassCheckerAcceptsBothNils
{
   GHAssertTrue( class_srcIsSuperclassOfDest   ( Nil, Nil ), @"Valid hierarchy not recognized" );
   GHAssertTrue( class_isClassesInSameHierarchy( Nil, Nil ), @"Valid hierarchy not recognized" );
}

@end
