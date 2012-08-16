#import <JFFUtils/Blocks/JFFOnDeallocBlockOwner.h>

@interface JFFOnDeallocBlockOwnerTest : GHTestCase
@end

@implementation JFFOnDeallocBlockOwnerTest

-(void)testOnDeallocBlockOwnerBehavior
{
    __block BOOL blockCalled_ = NO;
    __block BOOL blockContextDeallocated_ = NO;

    @autoreleasepool
    {
        NSObject* blockContext_ = [ NSObject new ];
        [ blockContext_ addOnDeallocBlock: ^void( void )
        {
            blockContextDeallocated_ = YES;
        } ];

        JFFOnDeallocBlockOwner* owner_ = [ [ JFFOnDeallocBlockOwner alloc ] initWithBlock: ^void( void )
        {
            if ( [ blockContext_ description ] )
                blockCalled_ = YES;
        } ];

        GHAssertFalse( blockContextDeallocated_ && owner_, @"Block context should not be dealloced" );
        GHAssertFalse( blockCalled_, @"block should not be called here" );
    }

    GHAssertTrue( blockContextDeallocated_, @"Block context should be dealloced" );
    GHAssertTrue( blockCalled_, @"block should be called here" );
}

@end
