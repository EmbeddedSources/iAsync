#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"
#import "JFFAddressBookAccessError.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncRequestAccessToContactsLoader : NSObject < JFFAsyncOperationInterface >
@end

@implementation JFFAsyncRequestAccessToContactsLoader

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    NSParameterAssert(handler);
    handler = [handler  copy];
    
    JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book) {
        
        handler(book, nil);
    };
    
    JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
        if (handler) {
            
            JFFAddressBookAccessError *resError = [JFFAddressBookAccessError new];
            resError.nativeError = error;
            handler(nil, resError);
        }
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
    JFFAsyncOperationBinder contats = ^JFFAsyncOperation(JFFAddressBook *book) {
        
        return asyncOperationWithAnalyzer(nil, ^id(id result, NSError *__autoreleasing *outError) {
            
            return [JFFContact allContactsAddressBook:book];
        });
    };
    return bindSequenceOfAsyncOperations(requestAccessToContactsLoader(), contats, nil);
}

JFFAsyncOperation requestAccessToContactsLoader()
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncRequestAccessToContactsLoader new];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
