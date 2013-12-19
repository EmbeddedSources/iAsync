#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@interface JFFNetworkResponseDataCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic, strong) NSData *dataChunk;

@property ( nonatomic ) unsigned long long downloadedBytesCount;
@property ( nonatomic ) unsigned long long totalBytesCount;

@end
