#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface JNNsUrlConnection : JNAbstractConnection

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_;

-(void)start;
-(void)cancel;

@end
