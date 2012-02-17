#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@interface JNAbstractConnection : NSObject < JNUrlConnection >

@property ( nonatomic, copy ) ESDidReceiveResponseHandler didReceiveResponseBlock;
@property ( nonatomic, copy ) ESDidReceiveDataHandler     didReceiveDataBlock    ;
@property ( nonatomic, copy ) ESDidFinishLoadingHandler   didFinishLoadingBlock  ;
@property ( nonatomic, copy ) ShouldAcceptCertificateForHost shouldAcceptCertificateBlock;

-(void)clearCallbacks;

@end
