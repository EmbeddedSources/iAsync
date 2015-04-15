#import <JFFNetwork/JNAbstractConnection.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

//JFFURLConnection can not be reused after cancel or finish
//all callbacks cleared after cancel or finish action
@interface JFFURLConnection : JNAbstractConnection

- (instancetype)initWithURLConnectionParams:(JFFURLConnectionParams *)params;

- (void)start;
- (void)cancel;

@end
