#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@interface JNAbstractConnection : NSObject < JNUrlConnection >

@property (nonatomic, copy) JFFDidReceiveResponseHandler didReceiveResponseBlock;
@property (nonatomic, copy) JFFDidReceiveDataHandler     didReceiveDataBlock    ;
@property (nonatomic, copy) JFFDidFinishLoadingHandler   didFinishLoadingBlock  ;
@property (nonatomic, copy) JFFDidUploadDataHandler      didUploadDataBlock     ;
@property (nonatomic, copy) JFFShouldAcceptCertificateForHost shouldAcceptCertificateBlock;

- (unsigned long long)downloadedBytesCount;
- (unsigned long long)totalBytesCount;

- (void)clearCallbacks;

@end
