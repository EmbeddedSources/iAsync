#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@interface JFFNetworkResponseDataCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic) NSData *dataChunk;

@property (nonatomic) unsigned long long downloadedBytesCount;
@property (nonatomic) unsigned long long totalBytesCount;


@end
