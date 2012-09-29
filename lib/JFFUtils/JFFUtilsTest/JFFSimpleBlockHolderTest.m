#import "JFFSimpleBlockHolderTest.h"

@implementation JFFSimpleBlockHolderTest

-(void)setUp
{
    [JFFSimpleBlockHolder enableInstancesCounting];
}

-(void)testSimpleBlockHolderBehavior
{
    @autoreleasepool {
        JFFSimpleBlockHolder* holder_ = [ JFFSimpleBlockHolder new ];
        STAssertTrue( 0 != [ JFFSimpleBlockHolder instancesCount ], @"Block holder should exists" );
        
        __block BOOL blockContextDeallocated_ = NO;
        __block NSUInteger performBlockCount_ = 0;
        
        @autoreleasepool {
            NSObject *blockContext_ = [NSObject new];
            [ blockContext_ addOnDeallocBlock: ^void( void )
             {
                 blockContextDeallocated_ = YES;
             } ];
            
            holder_.simpleBlock = ^void( void )
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                if ( [ blockContext_ class ] && [ holder_ class ] )
                    ++performBlockCount_;
#pragma clang diagnostic pop
            };
            
            holder_.onceSimpleBlock();
            holder_.onceSimpleBlock();
        }
        
        STAssertTrue( blockContextDeallocated_, @"Block context should be dealloced" );
        STAssertTrue( 1 == performBlockCount_, @"Block was called once" );
        STAssertTrue( nil == holder_.simpleBlock, @"Block is nil after call" );
    }
    
    STAssertTrue( 0 == [ JFFSimpleBlockHolder instancesCount ], @"Block holder should be dealloced" );
}

@end
