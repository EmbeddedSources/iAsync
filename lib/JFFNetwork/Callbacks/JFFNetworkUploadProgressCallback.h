#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>
#import <JFFNetwork/Callbacks/JFFUploadProgress.h>

@class JFFURLConnectionParams;

@interface JFFNetworkUploadProgressCallback : JFFNetworkAsyncOperationCallback<JFFUploadProgress>

@property (nonatomic, strong) NSNumber *progress;
@property (nonatomic, strong) JFFURLConnectionParams *params;

@end
