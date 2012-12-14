#import <JFFNetwork/Callbacks/JFFNetworkAsyncOperationCallback.h>

@interface JFFNetworkResponseDataCallback : JFFNetworkAsyncOperationCallback

@property (nonatomic) NSData *dataChunk;

@end
