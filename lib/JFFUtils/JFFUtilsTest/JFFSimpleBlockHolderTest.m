#import "JFFSimpleBlockHolderTest.h"

@implementation JFFSimpleBlockHolderTest

-(void)setUp
{
    [JFFSimpleBlockHolder enableInstancesCounting];
}

-(void)testSimpleBlockHolderBehavior
{
    @autoreleasepool {
        JFFSimpleBlockHolder* holder = [ JFFSimpleBlockHolder new ];
        STAssertTrue( 0 != [ JFFSimpleBlockHolder instancesCount ], @"Block holder should exists" );
        
        __block BOOL blockContextDeallocated = NO;
        __block NSUInteger performBlockCount = 0;
        
        @autoreleasepool {
            NSObject *blockContext = [NSObject new];
            [ blockContext addOnDeallocBlock: ^void( void )
             {
                 blockContextDeallocated = YES;
             } ];
            
            holder.simpleBlock = ^void( void )
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                if ([blockContext class] && [holder class])
                    ++performBlockCount;
#pragma clang diagnostic pop
            };
            
            holder.onceSimpleBlock();
            holder.onceSimpleBlock();
        }
        
        STAssertTrue(blockContextDeallocated, @"Block context should be dealloced");
        STAssertTrue(1 == performBlockCount, @"Block was called once");
        STAssertTrue(nil == holder.simpleBlock, @"Block is nil after call");
    }
    
    STAssertTrue( 0 == [ JFFSimpleBlockHolder instancesCount ], @"Block holder should be dealloced" );
}

@end
