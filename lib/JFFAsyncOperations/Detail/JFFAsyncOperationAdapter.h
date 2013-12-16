#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#import "JFFAsyncOperationInterface.h"

#include <string>

@class JFFBlockOperation;

@interface JFFAsyncOperationAdapter : NSObject <JFFAsyncOperationInterface>

@property (nonatomic, copy) JFFSyncOperationWithProgress loadDataBlock;
@property (nonatomic) JFFBlockOperation *operation;
@property (nonatomic) std::string queueName;
@property (nonatomic) BOOL barrier;

//DISPATCH_QUEUE_CONCURRENT by default
@property (nonatomic) dispatch_queue_t currentQueue;
@property (nonatomic) dispatch_queue_attr_t queueAttributes;

//DISPATCH_QUEUE_CONCURRENT by default
@property ( nonatomic ) dispatch_queue_attr_t queueAttributes;

@end
