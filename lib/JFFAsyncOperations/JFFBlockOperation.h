#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

//JTODO remove
@interface JFFBlockOperation : NSObject

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )loadDataBlock_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_;

-(void)cancel;

@end
