#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface JNNsUrlConnection : JNAbstractConnection

//!c TODO : add an opportunity to change the request. (JTODO ask)
-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_;

-(void)start;
-(void)cancel;

@end
