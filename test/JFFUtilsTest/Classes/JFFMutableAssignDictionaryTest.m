#import <JFFUtils/JFFMutableAssignDictionary.h>

@interface JFFMutableAssignDictionaryTest : GHTestCase
@end

@implementation JFFMutableAssignDictionaryTest

-(void)testMutableAssignDictionaryAssignIssue
{
    NSObject* target_ = [ NSObject new ];

    __block BOOL targetDeallocated_ = NO;
    [ target_ addOnDeallocBlock: ^void( void )
    {
        targetDeallocated_ = YES;
    } ];

    JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];
    [ dict_ setObject: target_ forKey: @"1" ];

    GHAssertTrue( 1 == [ dict_ count ], @"Contains 1 object" );

    [ target_ release ];

    GHAssertTrue( targetDeallocated_, @"Target should be dealloced" );
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
    @autoreleasepool
    {
        JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

        __block BOOL target_deallocated_ = NO;
        @autoreleasepool
        {
            NSObject* object1_ = [ NSObject new ];
            NSObject* object2_ = [ NSObject new ];

            [ object1_ addOnDeallocBlock: ^void( void )
            {
                target_deallocated_ = YES;
            } ];

            [ dict_ setObject: object1_ forKey: @"1" ];
            [ dict_ setObject: object2_ forKey: @"2" ];

            GHAssertTrue( [ dict_ objectForKey: @"1" ] == object1_, @"Dict contains object_" );
            GHAssertTrue( [ dict_ objectForKey: @"2" ] == object2_, @"Dict contains object_" );
            GHAssertTrue( [ dict_ objectForKey: @"3" ] == nil, @"Dict no contains object for key \"2\"" );

            __block NSUInteger count_ = 0;

            [ dict_ enumerateKeysAndObjectsUsingBlock: ^( id key, id obj, BOOL *stop )
            {
                if ( [ key isEqualToString: @"1" ] )
                {
                    GHAssertTrue( obj == object1_, @"OK" );
                    ++count_;
                }
                else if ( [ key isEqualToString: @"2" ] )
                {
                    GHAssertTrue( obj == object2_, @"OK" );
                    ++count_;
                }
                else
                {
                    GHFail( @"should not be reached" );
                }
            } ];

            GHAssertTrue( count_ == 2, @"Dict no contains object for key \"2\"" );

            [ object1_ release ];
            [ object2_ release ];
        }

        GHAssertTrue( target_deallocated_, @"Target should be dealloced" );

        GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );

        [ dict_ release ];
    }
}

-(void)testReplaceObjectInDict
{
    JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

    @autoreleasepool
    {
        __block BOOL replacedObjectDealloced_ = NO;
        NSObject* object_ = nil;

        @autoreleasepool
        {
            NSObject* replacedObject_ = [ NSObject new ];
            [ replacedObject_ addOnDeallocBlock: ^void()
            {
                replacedObjectDealloced_ = YES;
            } ];

            object_ = [ NSObject new ];

            [ dict_ setObject: replacedObject_ forKey: @"1" ];

            GHAssertTrue( [ dict_ objectForKey: @"1" ] == replacedObject_, @"Dict contains object_" );
            GHAssertTrue( [ dict_ objectForKey: @"2" ] == nil, @"Dict no contains object for key \"2\"" );

            [ dict_ setObject: object_ forKey: @"1" ];
            GHAssertTrue( [ dict_ objectForKey: @"1" ] == object_, @"Dict contains object_" );

            [ replacedObject_ release ];
        }

        GHAssertTrue( replacedObjectDealloced_, @"OK" );

        NSObject* current_object_ = [ dict_ objectForKey: @"1" ];
        GHAssertTrue( current_object_ == object_, @"OK" );

        [ object_ release ];
    }

    GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );

    [ dict_ release ];
}

@end
