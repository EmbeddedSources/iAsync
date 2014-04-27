#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFPurchsing : NSObject

+ (JFFAsyncOperation)purcheserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback;

//should return [srvResult, transaction] in doneCallback
+ (JFFAsyncOperation)purcheserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback;

@end
