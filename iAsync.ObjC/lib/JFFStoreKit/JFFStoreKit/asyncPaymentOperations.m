#import "asyncPaymentOperations.h"

#import "asyncSKPaymentQueue.h"
#import "appStoreReceiptData.h"
#import "asyncSKProductRequest.h"
#import "asyncSKFinishTransaction.h"

@implementation JFFPurchsing

+ (JFFAsyncOperation)purchaserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback
                                recallSrvWithResult:(JFFPredicateBlock)recallSrvWithResult
                          productIDsFromSrvResponse:(JFFMappingBlock)productIDsFromSrvResponse
{
    srvCallback               = [srvCallback         copy];
    recallSrvWithResult       = [recallSrvWithResult copy];
    productIDsFromSrvResponse = [productIDsFromSrvResponse copy];
    
    JFFAsyncOperation productLoader = skProductLoaderWithProductIdentifier(productIdentifier);
    
    JFFAsyncOperationBinder paymentBinder = ^JFFAsyncOperation(SKProduct *product) {
        return [self purchaserWithProduct:product
                              srvCallback:srvCallback
                      recallSrvWithResult:recallSrvWithResult
                productIDsFromSrvResponse:productIDsFromSrvResponse];
    };
    
    return bindSequenceOfAsyncOperations(productLoader,
                                         paymentBinder,
                                         nil);
}

+ (JFFAsyncOperation)purchaserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback
                      recallSrvWithResult:(JFFPredicateBlock)recallSrvWithResult
                productIDsFromSrvResponse:(JFFMappingBlock)productIDsFromSrvResponse
{
    srvCallback               = [srvCallback               copy];
    recallSrvWithResult       = [recallSrvWithResult       copy];
    productIDsFromSrvResponse = [productIDsFromSrvResponse copy];
    
    //TODO repeate srvLoader until buy products
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFAsyncOperation (^processPayment)(BOOL) = ^JFFAsyncOperation(BOOL failIfNoProductsIDs) {
            
            //1. close previous transactions
            JFFAsyncOperation processTransactions = bindSequenceOfAsyncOperations(appStoreReceiptDataLoader(), ^(NSData *appStoreReceiptData) {
                NSString *result = [appStoreReceiptData base64EncodedStringWithOptions:(0)];
                return srvCallback(result);
            }, nil);
            
            JFFAsyncOperationBinder closeTranactions = ^JFFAsyncOperation(NSArray *productIDs) {
                
                if (failIfNoProductsIDs && ![productIDs lastObject]) {
                    NSError *error = [JFFError newErrorWithDescription:@"no srv transactions - TODO fix!"];
                    return asyncOperationWithError(error);
                }
                
                JFFAsyncOperation noError = asyncOperationWithResult(@[]);
                return trySequenceOfAsyncOperations(asyncOperationFinishTransactionsForProducts(productIDs),
                                                    noError,
                                                    nil);
            };
            
            JFFAsyncOperationBinder closeTransactionsAndReturnServerResult = ^(id nativeServerResult) {
                
                NSArray *productIDs = productIDsFromSrvResponse(nativeServerResult);
                return sequenceOfAsyncOperations(closeTranactions(productIDs), asyncOperationWithResult(nativeServerResult), nil);
            };
            
            JFFAsyncOperation srvProcessAndCloseTransactions = bindSequenceOfAsyncOperations(processTransactions,
                                                                                             closeTransactionsAndReturnServerResult,
                                                                                             nil);
            
            return srvProcessAndCloseTransactions;
        };
        
        JFFAsyncOperationBinder makePayment = ^(id nativeServerResult) {
            
            if (!recallSrvWithResult(nativeServerResult)) {
                return asyncOperationWithResult(nativeServerResult);
            }
            
            //Make payment
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            JFFAsyncOperation paymentLoader = asyncOperationWithSKPayment(payment);
            
            JFFAsyncOperation noError = asyncOperationWithResult(@[]);
            JFFAsyncOperation closeTranactions = trySequenceOfAsyncOperations(asyncOperationFinishTransactionsForProducts(@[payment.productIdentifier]),
                                                                              noError,
                                                                              nil);
            
            return sequenceOfAsyncOperations(closeTranactions, paymentLoader, processPayment(YES), nil);
        };
        
        JFFAsyncOperation loader = bindSequenceOfAsyncOperations(processPayment(NO),
                                                                 makePayment,
                                                                 nil);
        
        return loader(progressCallback, stateCallback, doneCallback);
    };
}

@end
