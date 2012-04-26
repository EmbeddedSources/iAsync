@interface MockTest : GHTestCase
@end

@implementation MockTest

-(void)aFunctionThatThrows
{
   NSAssert( NO, @"An assert for the example" );
}

-(void)testMockTestReallyExistsAndCanSucceedWithoutActions
{
}

-(void)testMockTestReallyExistsAndCanSucceed
{
   GHAssertTrue( 2 + 2 == 4, @"Primitive math must always work" );
   GHAssertTrue( [ @"received" isEqualToString:@"received" ], @"Primitive math must always work" );

   GHAssertThrows( [ self aFunctionThatThrows ], @"NSAssert exception expected" );
   GHAssertNoThrow( [ self testMockTestReallyExistsAndCanSucceedWithoutActions ], @"No exceptions expected" );   
}

-(void)testMockTestReallyExistsAndCanFail
{
   //GHFail( @"Failing is fun" );
}


@end
