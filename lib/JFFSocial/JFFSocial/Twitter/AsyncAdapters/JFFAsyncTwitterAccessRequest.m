#import "JFFAsyncTwitterAccessRequest.h"

#import "JFFTwitterAccountAccessNotGrantedError.h"

#import <Accounts/Accounts.h>

@interface JFFAsyncTwitterAccessRequest : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterAccessRequest

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    ACAccountStore *accountStore = [ACAccountStore new];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error) {
        
        if (!handler)
            return;
        
        if (error) {
            handler(nil, error);
        } else {
            if (granted) {
                handler([NSNull new], nil);
            } else {
                handler(nil, [JFFTwitterAccountAccessNotGrantedError new]);
            }
        }
    }];
}

- (BOOL)isForeignThreadResultCallback
{
    return YES;
}

@end

JFFAsyncOperation jffTwitterAccessRequestLoader()
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncTwitterAccessRequest new];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
