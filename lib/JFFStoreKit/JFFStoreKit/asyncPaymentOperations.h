#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFPurchsing : NSObject

+ (JFFAsyncOperation)purchaserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback;

//should return [srvResult, transaction] in doneCallback
+ (JFFAsyncOperation)purchaserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback;

@end
