#import <JFFNetwork/JNUrlConnection.h>
#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

@interface JNNsUrlConnection : JNAbstractConnection

//!c TODO : add an opportunity to change the request.
-(id)initWithRequest:( NSURLRequest* )request_;

-(void)start;
-(void)cancel;

@end
