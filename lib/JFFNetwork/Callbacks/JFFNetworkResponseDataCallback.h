#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@interface JFFNetworkResponseDataCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic, strong) NSData *dataChunk;

@end
