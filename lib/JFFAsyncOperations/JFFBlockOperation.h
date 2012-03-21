#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

//JTODO remove
@interface JFFBlockOperation : NSObject

+(id)performOperationWithLoadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
                         progressBlock:( JFFAsyncOperationProgressHandler )progressBlock_;

-(void)cancel;

@end
