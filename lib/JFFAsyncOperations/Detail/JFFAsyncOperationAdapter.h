#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationInterface.h"

#include <string>

@class JFFBlockOperation;

@interface JFFAsyncOperationAdapter : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy   ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic ) JFFBlockOperation* operation;
@property ( nonatomic ) std::string queueName;
@property ( nonatomic ) BOOL barrier;

@end
