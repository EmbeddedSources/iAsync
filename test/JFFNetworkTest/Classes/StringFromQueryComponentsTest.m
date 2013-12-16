
@interface StringFromQueryComponentsTest : GHTestCase
@end

@implementation StringFromQueryComponentsTest

- (void)testStringFromQueryComponentsTest
{
    NSString* key1_ = @"a";
    NSString* key2_ = @"a b";
    NSString* key3_ = @"c";

    NSString* valueA_ = @"valueA";

    NSDictionary* dict_ = @{key1_: valueA_
                           , key2_: @[@"a", @"b"]
                           , key3_: @[]};
    
    NSString* str_ = [ dict_ stringFromQueryComponents ];
    
    NSDictionary *newDict_ = [ str_ dictionaryFromQueryComponents ];

    GHAssertTrue([newDict_ count ] == 2, @"OK" );

    NSString* argValueA_ = [ newDict_ firstValueIfExsistsForKey: key1_ ];

    GHAssertTrue([valueA_ isEqualToString: argValueA_ ], @"OK" );

    NSArray* ABvalues_ = newDict_[key2_];

    GHAssertTrue([ABvalues_ count ] == 2, @"OK" );

    GHAssertTrue([ ABvalues_ containsObject: @"a" ], @"OK" );
    GHAssertTrue([ ABvalues_ containsObject: @"b" ], @"OK" );
}

@end
