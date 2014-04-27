#import "JFFAsyncTwitterAccessRequest.h"

#import "JFFTwitterAccountAccessNotGrantedError.h"

#import <Accounts/Accounts.h>

@interface JFFAsyncTwitterAccessRequest : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterAccessRequest

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    
    ACAccountStore *accountStore = [ACAccountStore new];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error) {
        
        if (!finishCallback)
            return;
        
        if (error) {
            finishCallback(nil, error);
        } else {
            if (granted) {
                finishCallback([NSNull new], nil);
            } else {
                finishCallback(nil, [JFFTwitterAccountAccessNotGrantedError new]);
            }
        }
    }];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
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
