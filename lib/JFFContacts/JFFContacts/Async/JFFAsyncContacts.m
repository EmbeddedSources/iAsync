#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncRequestAccessToContactsLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncRequestAccessToContactsLoader

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    NSParameterAssert(handler);
    handler = [handler copy];
    
    JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book) {
        
        handler(book, nil);
    };
    
    JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
        
        handler(nil, error);
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation asyncAllContactsLoader()
{
    JFFAsyncOperationBinder contacts = ^JFFAsyncOperation(JFFAddressBook *book) {
        
        return asyncOperationWithAnalyzer(nil, ^id(id result, NSError *__autoreleasing *outError) {
            
            return [JFFContact allContactsAddressBook:book];
        });
    };
    return bindSequenceOfAsyncOperations(requestAccessToContactsLoader(), contacts, nil);
}

JFFAsyncOperation requestAccessToContactsLoader()
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncRequestAccessToContactsLoader new];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
