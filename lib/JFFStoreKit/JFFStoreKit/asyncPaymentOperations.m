#import "asyncPaymentOperations.h"

#import "asyncSKPaymentQueue.h"
#import "appStoreReceiptData.h"
#import "asyncSKProductRequest.h"
#import "asyncSKFinishTransaction.h"

@implementation JFFPurchsing

+ (JFFAsyncOperation)purchaserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback
{
    srvCallback = [srvCallback copy];
    
    JFFAsyncOperation productLoader = skProductLoaderWithProductIdentifier(productIdentifier);
    
    JFFAsyncOperationBinder paymentBinder = ^JFFAsyncOperation(SKProduct *product) {
        return [self purchaserWithProduct:product srvCallback:srvCallback];
    };
    
    return bindSequenceOfAsyncOperations(productLoader,
                                         paymentBinder,
                                         nil);
}

+ (JFFAsyncOperation)purchaserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback
{
    srvCallback = [srvCallback copy];
    
    //TODO repeate srvLoader until buy products
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFAsyncOperation (^loadTransactionIDs)(BOOL) = ^JFFAsyncOperation(BOOL failIfNoTransactions) {
            
            //1. close previous transactions
            JFFAsyncOperation processTransactions = bindSequenceOfAsyncOperations(appStoreReceiptDataLoader(), ^(NSData *appStoreReceiptData) {
                NSString *result = [appStoreReceiptData base64EncodedStringWithOptions:(0)];
                return srvCallback(result);
            }, nil);
            
            JFFAsyncOperationBinder closeTranactions = ^JFFAsyncOperation(NSArray *productIDs) {
                
                if (failIfNoTransactions && ![productIDs lastObject]) {
                    NSError *error = [JFFError newErrorWithDescription:@"no srv transactions - TODO fix!"];
                    return asyncOperationWithError(error);
                }
                
                JFFAsyncOperation noError = asyncOperationWithResult(@[]);
                return trySequenceOfAsyncOperations(asyncOperationFinishTransactionsForProducts(productIDs),
                                                    noError,
                                                    nil);
            };
            
            JFFAsyncOperation srvProcessAndCloseTransactions = bindSequenceOfAsyncOperations(processTransactions, closeTranactions, nil);
            
            return srvProcessAndCloseTransactions;
        };
        
        //Make payment
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        JFFAsyncOperation paymentLoader = asyncOperationWithSKPayment(payment);
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(loadTransactionIDs(NO),
                                                             paymentLoader,
                                                             loadTransactionIDs(YES),
                                                             nil);
        
        return loader(progressCallback, stateCallback, doneCallback);
    };
}

@end
