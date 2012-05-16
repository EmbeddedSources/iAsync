#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#import "JFFAsyncOperationBuilder.h"

@class JFFBlockOperation;

@interface JFFAsyncOperationOperation : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy   ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic ) JFFBlockOperation* operation;
@property ( nonatomic ) NSString* queueName;
@property ( nonatomic ) BOOL concurrent;

@end
