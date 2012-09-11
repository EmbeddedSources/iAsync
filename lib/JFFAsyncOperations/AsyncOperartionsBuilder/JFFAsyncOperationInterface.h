#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFAsyncOperationInterfaceHandler)(id, NSError *);
typedef void (^JFFAsyncOperationInterfaceProgressHandler)(id);

@protocol JFFAsyncOperationInterface < NSObject >

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress;

- (void)cancel:(BOOL)canceled;

@end
