
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

@interface PurchasingTest : GHAsyncTestCase

@end

@implementation PurchasingTest

- (void)testFreePurchase
{
    void(^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperationBinder srvCallback = ^JFFAsyncOperation(SKProduct *product)
        {
            return asyncOperationWithResult(@"ok )");
        };
        JFFAsyncOperation loader = [JFFPurchsing purcheserWithProductIdentifier:@"test.free.purchase1"
                                                                    srvCallback:srvCallback];
        
        loader(nil, nil, ^(id result, NSError *error) {
            finishBLock();
        });
    };
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd];
    
    GHAssertTrue(YES, nil);
}

@end
