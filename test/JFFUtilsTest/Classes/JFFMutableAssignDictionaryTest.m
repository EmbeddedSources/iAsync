#import <JFFUtils/JFFMutableAssignDictionary.h>

@interface JFFMutableAssignDictionaryTest : GHTestCase
@end

@implementation JFFMutableAssignDictionaryTest

-(void)testMutableAssignDictionaryAssignIssue
{
    JFFMutableAssignDictionary* dict_;
    __block BOOL targetDeallocated_ = NO;
    {
        NSObject* target_ = [ NSObject new ];

        [ target_ addOnDeallocBlock: ^void( void )
        {
            targetDeallocated_ = YES;
        } ];

        dict_ = [ JFFMutableAssignDictionary new ];
        [ dict_ setObject: target_ forKey: @"1" ];

        GHAssertTrue( 1 == [ dict_ count ], @"Contains 1 object" );
    }

    GHAssertTrue( targetDeallocated_, @"Target should be dealloced" );
    GHAssertTrue( 0 == [ dict_ count ], @"Empty array" );
}

-(void)testMutableAssignDictionaryFirstRelease
{
    __block BOOL dict_deallocated_ = NO;
    {
        JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];

        [ dict_ addOnDeallocBlock: ^void( void )
        {
            dict_deallocated_ = YES;
        } ];

        NSObject* target_ = [ NSObject new ];
        [ dict_ setObject: target_ forKey: @"1" ];
    }

    GHAssertTrue( dict_deallocated_, @"Target should be dealloced" );
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
        }

        GHAssertTrue( target_deallocated_, @"Target should be dealloced" );

        GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );
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
        }

        GHAssertTrue( replacedObjectDealloced_, @"OK" );

        NSObject* current_object_ = [ dict_ objectForKey: @"1" ];
        GHAssertTrue( current_object_ == object_, @"OK" );
    }

    GHAssertTrue( 0 == [ dict_ count ], @"Empty dict" );
}

@end
