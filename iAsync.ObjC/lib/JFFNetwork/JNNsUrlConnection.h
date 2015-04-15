#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface JNNsUrlConnection : JNAbstractConnection

- (instancetype)initWithURLConnectionParams:(JFFURLConnectionParams *)params;

- (void)start;
- (void)cancel;

@end
