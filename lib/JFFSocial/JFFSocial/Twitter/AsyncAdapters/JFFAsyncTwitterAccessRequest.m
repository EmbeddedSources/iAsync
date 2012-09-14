#import "JFFAsyncTwitterAccessRequest.h"

#import "JFFTwitterAccountAccessNotGrantedError.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface JFFAsyncTwitterAccessRequest : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterAccessRequest

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void(^)(id))progress
{
    handler  = [handler copy];
    progress = [progress copy];

    ACAccountStore *accountStore = [ACAccountStore new];

    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error)
    {
        if (!handler)
            return;

        if (error)
        {
            handler(nil, error);
        }
        else
        {
            if (granted)
            {
                handler([NSNull null], nil);
            }
            else
            {
                handler(nil, [JFFTwitterAccountAccessNotGrantedError new]);
            }
        }
    }];
}

-(void)cancel:( BOOL )canceled_
{
}

@end

JFFAsyncOperation jffTwitterAccessRequestLoader()
{
    return buildAsyncOperationWithInterface([JFFAsyncTwitterAccessRequest new]);
}
