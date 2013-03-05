#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@class JFFURLConnectionParams;

@interface JFFNetworkUploadProgressCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic, strong) NSNumber *progress;
@property (nonatomic, strong) JFFURLConnectionParams *params;

@end
