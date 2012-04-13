#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@interface JFFSimpleBlockHolderTest : GHTestCase
@end

@implementation JFFSimpleBlockHolderTest

-(void)testSimpleBlockHolderBehavior
{
    @autoreleasepool
    {
        JFFSimpleBlockHolder* holder_ = [ JFFSimpleBlockHolder new ];
        GHAssertTrue( 0 < [ JFFSimpleBlockHolder instancesCount ], @"Block holder should exists" );

        __block BOOL blockContextDeallocated_ = NO;
        __block NSUInteger performBlockCount_ = 0;

        @autoreleasepool
        {
            NSObject* block_context_ = [ NSObject new ];
            [ block_context_ addOnDeallocBlock: ^void( void )
            {
                blockContextDeallocated_ = YES;
            } ];

            holder_.simpleBlock = ^void( void )
            {
                if ( [ block_context_ class ] && [ holder_ class ] )
                    ++performBlockCount_;
            };

            holder_.onceSimpleBlock();
            holder_.onceSimpleBlock();

            [ block_context_ release ];
        }

        GHAssertTrue( blockContextDeallocated_, @"Block context should be dealloced" );
        GHAssertTrue( 1 == performBlockCount_, @"Block was called once" );
        GHAssertTrue( nil == holder_.simpleBlock, @"Block is nil after call" );

        [ holder_ release ];
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder instancesCount ], @"Block holder should be dealloced" );
}

@end
