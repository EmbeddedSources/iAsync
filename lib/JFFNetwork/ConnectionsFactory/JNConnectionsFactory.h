#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface JNConnectionsFactory : NSObject 

@property ( nonatomic, retain, readonly ) JFFURLConnectionParams* params;

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_;

-(id< JNUrlConnection >)createFastConnection;
-(id< JNUrlConnection >)createStandardConnection;

@end
