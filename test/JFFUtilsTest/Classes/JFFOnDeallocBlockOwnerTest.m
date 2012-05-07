#import <JFFUtils/Blocks/JFFOnDeallocBlockOwner.h>

@interface JFFOnDeallocBlockOwnerTest : GHTestCase
@end

@implementation JFFOnDeallocBlockOwnerTest

-(void)testOnDeallocBlockOwnerBehavior
{
    __block BOOL block_called_ = NO;
    __block BOOL block_context_deallocated_ = NO;

    @autoreleasepool
    {
        NSObject* block_context_ = [ NSObject new ];
        [ block_context_ addOnDeallocBlock: ^void( void )
        {
            block_context_deallocated_ = YES;
        } ];

        JFFOnDeallocBlockOwner* owner_ = [ [ JFFOnDeallocBlockOwner alloc ] initWithBlock: ^void( void )
        {
            if ( [ block_context_ description ] )
                block_called_ = YES;
        } ];

        GHAssertFalse( block_context_deallocated_ && owner_, @"Block context should not be dealloced" );
        GHAssertFalse( block_called_, @"block should not be called here" );
    }

    GHAssertTrue( block_context_deallocated_, @"Block context should be dealloced" );
    GHAssertTrue( block_called_, @"block should be called here" );
}

@end
