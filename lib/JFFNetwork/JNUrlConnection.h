#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <Foundation/Foundation.h>

@protocol JNUrlConnection < NSObject >

@required
   -(void)start;
   -(void)cancel;

@required
   //callbacks cleared after finish of loading
   @property ( nonatomic, copy ) JFFDidReceiveResponseHandler didReceiveResponseBlock;
   @property ( nonatomic, copy ) JFFDidReceiveDataHandler     didReceiveDataBlock    ;
   @property ( nonatomic, copy ) JFFDidFinishLoadingHandler   didFinishLoadingBlock  ;
   @property ( nonatomic, copy ) JFFShouldAcceptCertificateForHost shouldAcceptCertificateBlock;

@end
