#import <JFFNetwork/Errors/JNetworkError.h>

#import <Foundation/Foundation.h>

@interface JNSNetworkError : JNetworkError

@property (nonatomic, readonly) id<NSCopying> context;
@property (nonatomic, readonly) NSError *nativeError;

+ (instancetype)newJNSNetworkErrorWithContext:(id<NSCopying>)context
                                  nativeError:(NSError *)nativeError;

@end
