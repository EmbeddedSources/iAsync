#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFAsyncOperationInterfaceResultHandler)(id, NSError *);
typedef void (^JFFAsyncOperationInterfaceCancelHandler)(BOOL canceled);
typedef void (^JFFAsyncOperationInterfaceProgressHandler)(id);

@protocol JFFAsyncOperationInterface <NSObject>

@required
- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress;

@optional
- (void)cancel:(BOOL)canceled;

- (BOOL)isForeignThreadResultCallback;

@end
