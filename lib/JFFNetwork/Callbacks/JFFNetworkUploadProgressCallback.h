#import <JFFNetwork/Callbacks/JFFUploadProgress.h>

@class JFFURLConnectionParams;

@interface JFFNetworkUploadProgressCallback : NSObject <JFFUploadProgress>

@property (nonatomic) NSNumber *progress;
@property (nonatomic) JFFURLConnectionParams *params;

@end
