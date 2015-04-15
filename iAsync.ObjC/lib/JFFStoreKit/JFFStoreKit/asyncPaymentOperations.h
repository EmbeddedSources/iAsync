#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#include <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFPurchsing : NSObject

+ (JFFAsyncOperation)purchaserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback
                                recallSrvWithResult:(JFFPredicateBlock)recallSrvWithResult
                          productIDsFromSrvResponse:(JFFMappingBlock)productIDsFromSrvResponse;

//should return [srvResult, transaction] in doneCallback
+ (JFFAsyncOperation)purchaserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback
                      recallSrvWithResult:(JFFPredicateBlock)recallSrvWithResult
                productIDsFromSrvResponse:(JFFMappingBlock)productIDsFromSrvResponse;

@end
