#import <JFFNetwork/Errors/JNetworkError.h>

#import <Foundation/Foundation.h>

@interface JStreamError : JNetworkError

@property (nonatomic, readonly) CFStreamError rawError;

- (instancetype)initWithStreamError:(CFStreamError)rawError
                            context:(id<NSCopying>)context;

@end
