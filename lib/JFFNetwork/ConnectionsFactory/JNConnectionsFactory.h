#import <Foundation/Foundation.h>

@protocol JNUrlConnection;

@class JFFURLConnectionParams;

@interface JNConnectionsFactory : NSObject 

- (instancetype)initWithURLConnectionParams:(JFFURLConnectionParams *)params;

- (id< JNUrlConnection >)createFastConnection;
- (id< JNUrlConnection >)createStandardConnection;

- (id< JNUrlConnection >)createConnection;

@end
