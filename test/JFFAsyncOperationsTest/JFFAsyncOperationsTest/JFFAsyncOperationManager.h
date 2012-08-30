#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFCancelAsyncOperationBlockHolder;
@class JFFDidFinishAsyncOperationBlockHolder;

@interface JFFAsyncOperationManager : NSObject

@property ( nonatomic ) BOOL finishAtLoading;
@property ( nonatomic ) BOOL failAtLoading;

@property ( nonatomic, copy, readonly ) JFFAsyncOperation loader;
@property ( nonatomic, readonly ) JFFDidFinishAsyncOperationBlockHolder* loaderFinishBlock;
@property ( nonatomic, readonly ) JFFCancelAsyncOperationBlockHolder* loaderCancelBlock;

@property ( nonatomic, readonly ) NSUInteger loadingCount;
@property ( nonatomic, readonly ) BOOL finished;
@property ( nonatomic, readonly ) BOOL canceled;
@property ( nonatomic, readonly ) BOOL cancelFlag;

-(void)clear;

@end
