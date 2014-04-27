#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>
#import <JFFNetwork/Callbacks/JFFUploadProgress.h>

@class JFFURLConnectionParams;

@interface JFFNetworkUploadProgressCallback : JFFNetworkAsyncOperationCallback <JFFUploadProgress>

@property (nonatomic) NSNumber *progress;
@property (nonatomic) JFFURLConnectionParams *params;

@end
