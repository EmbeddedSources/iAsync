
@interface StringFromQueryComponentsTest : GHTestCase
@end

@implementation StringFromQueryComponentsTest

-(void)testStringFromQueryComponentsTest
{
    NSString* key1_ = @"a";
    NSString* key2_ = @"a b";
    NSString* key3_ = @"c";

    NSString* valueA_ = @"valueA";

    NSDictionary* dict_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                           valueA_, key1_
                           , [ NSArray arrayWithObjects: @"a", @"b", nil ], key2_
                           , [ NSArray array ], key3_
                           , nil ];

    NSString* str_ = [ dict_ stringFromQueryComponents ];

    NSDictionary* newDict_ = [ str_ dictionaryFromQueryComponents ];

    GHAssertTrue( [ newDict_ count ] == 2, @"OK" );

    NSString* argValueA_ = [ newDict_ firstValueIfExsistsForKey: key1_ ];

    GHAssertTrue( [ valueA_ isEqualToString: argValueA_ ], @"OK" );

    NSArray* ABvalues_ = [ newDict_ objectForKey: key2_ ];

    GHAssertTrue( [ ABvalues_ count ] == 2, @"OK" );

    GHAssertTrue( [ ABvalues_ containsObject: @"a" ], @"OK" );
    GHAssertTrue( [ ABvalues_ containsObject: @"b" ], @"OK" );
}

@end
