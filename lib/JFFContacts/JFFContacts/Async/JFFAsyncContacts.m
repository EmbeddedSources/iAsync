#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncAllContactsLoader : NSObject < JFFAsyncOperationInterface >
@end

@implementation JFFAsyncAllContactsLoader

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler  = [handler  copy];
    progress = [progress copy];
    
    JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book)
    {
        NSArray *result = [JFFContact allContactsAddressBook:book];
        
        if (progress)
            progress(result);
        
        if (handler)
            handler(result, nil);
    };
    
    JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error)
    {
        if (handler)
            handler(nil, error);
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation asyncAllContactsLoader( void )
{
    return buildAsyncOperationWithInterface( [ JFFAsyncAllContactsLoader new ] );
}
