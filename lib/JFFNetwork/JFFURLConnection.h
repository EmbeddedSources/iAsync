#import <JFFNetwork/JNAbstractConnection.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

//JFFURLConnection can not be reused after cancel or finish
//all callbacks cleared after cancel or finish action
@interface JFFURLConnection : JNAbstractConnection

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_;

-(void)start;
-(void)cancel;

@end
