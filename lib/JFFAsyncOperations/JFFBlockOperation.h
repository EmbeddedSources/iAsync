#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFBlockOperation : NSObject

+(id)performOperationWithQueueName:( NSString* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
                     progressBlock:( JFFAsyncOperationProgressHandler )progressBlock_
                        concurrent:( BOOL )concurrent_;

+(id)performOperationWithQueueName:( NSString* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_;

-(void)cancel;

@end
