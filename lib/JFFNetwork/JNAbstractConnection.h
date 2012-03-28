#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@interface JNAbstractConnection : NSObject < JNUrlConnection >

@property ( nonatomic, copy ) JFFDidReceiveResponseHandler didReceiveResponseBlock;
@property ( nonatomic, copy ) JFFDidReceiveDataHandler     didReceiveDataBlock    ;
@property ( nonatomic, copy ) JFFDidFinishLoadingHandler   didFinishLoadingBlock  ;
@property ( nonatomic, copy ) JFFShouldAcceptCertificateForHost shouldAcceptCertificateBlock;

-(void)clearCallbacks;

@end
