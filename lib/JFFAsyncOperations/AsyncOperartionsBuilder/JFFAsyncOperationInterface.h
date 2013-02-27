#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFAsyncOperationInterfaceResultHandler)(id, NSError *);
typedef void (^JFFAsyncOperationInterfaceCancelHandler)(BOOL canceled);
typedef void (^JFFAsyncOperationInterfaceProgressHandler)(id);

@protocol JFFAsyncOperationInterface < NSObject >

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress;

- (void)cancel:(BOOL)canceled;

@end
