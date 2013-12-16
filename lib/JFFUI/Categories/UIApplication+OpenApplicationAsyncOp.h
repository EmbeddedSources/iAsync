#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <UIKit/UIKit.h>

@interface UIApplication (OpenApplicationAsyncOp)

- (JFFAsyncOperation)asyncOperationWithApplicationURL:(NSURL *)url;

@end
