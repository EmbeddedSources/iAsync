#import <Foundation/Foundation.h>

@protocol JNUrlConnection;

@class JFFURLConnectionParams;

@interface JNConnectionsFactory : NSObject 

- (id)initWithURLConnectionParams:(JFFURLConnectionParams *)params;

- (id< JNUrlConnection >)createFastConnection;
- (id< JNUrlConnection >)createStandardConnection;

- (id< JNUrlConnection >)createConnection;

@end
