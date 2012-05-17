#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFBlockOperation : NSObject

+(id)performOperationWithQueueName:( const char* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
                     progressBlock:( JFFAsyncOperationProgressHandler )progressBlock_
                           barrier:( BOOL )barrier_;

+(id)performOperationWithQueueName:( const char* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_;

-(void)cancel;

@end
