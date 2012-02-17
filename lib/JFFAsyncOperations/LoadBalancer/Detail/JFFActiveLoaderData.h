#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFActiveLoaderData : NSObject

@property ( nonatomic, copy ) JFFAsyncOperation nativeLoader;
@property ( nonatomic, copy ) JFFCancelAsyncOperation wrappedCancel;

@end
