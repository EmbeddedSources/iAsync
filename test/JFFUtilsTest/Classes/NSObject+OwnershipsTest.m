#import <JFFUtils/NSObject/NSObject+Ownerships.h>

@interface NSObjectOwnershipsExtensionTest : GHTestCase
@end

@implementation NSObjectOwnershipsExtensionTest

-(void)testObjectOwnershipsExtension
{
    __block BOOL owned_deallocated_ = NO;
    {
        NSObject* owner_ = [ NSObject new ];
        {
            NSObject* owned_ = [ NSObject new ];

            [ owned_ addOnDeallocBlock: ^void( void )
            {
                owned_deallocated_ = YES;
            } ];

            [ owner_.ownerships addObject: owned_ ];
        }

        GHAssertFalse( owned_deallocated_, @"Owned should not be dealloced" );
    }
    GHAssertTrue( owned_deallocated_, @"Owned should be dealloced" );
}

@end
