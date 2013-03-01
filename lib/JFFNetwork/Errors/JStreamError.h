#import <JFFNetwork/Errors/JNetworkError.h>
#import <CFNetwork/CFNetwork.h>

@interface JStreamError : JNetworkError

-(id)initWithStreamError:( CFStreamError )rawError_;

@property ( nonatomic, assign, readonly ) CFStreamError rawError;

@end
