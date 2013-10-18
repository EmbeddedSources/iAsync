#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@class JFFURLConnectionParams;

@interface JFFNetworkUploadProgressCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic) NSNumber *progress;
@property (nonatomic) JFFURLConnectionParams *params;

@end
