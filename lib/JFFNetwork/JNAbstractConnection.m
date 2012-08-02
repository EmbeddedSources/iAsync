#import "JNAbstractConnection.h"

@implementation JNAbstractConnection

#pragma mark -
#pragma mark Not Supported
-(void)start
{
    NSLog( @"[!!! ERROR !!!] : JNAbstractConnection->start is not supported. Please subclass it." );
    [ self doesNotRecognizeSelector: _cmd ];
}

-(void)cancel
{
    NSLog( @"[!!! ERROR !!!] : JNAbstractConnection->cancel is not supported. Please subclass it." );
    [ self doesNotRecognizeSelector: _cmd ];
}

#pragma mark -
#pragma mark Callbacks management
-(void)clearCallbacks
{
    self.didReceiveResponseBlock = nil;
    self.didReceiveDataBlock     = nil;
    self.didFinishLoadingBlock   = nil;
    self.shouldAcceptCertificateBlock = nil;
}

@end
