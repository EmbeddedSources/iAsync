#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncRequestAccessToContactsLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncRequestAccessToContactsLoader
{
    JFFAsyncOperationInterfaceResultHandler _handler;
}

- (void)notifyHandlerWithResult:(id)result error:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _handler(result, error);
    });
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    NSParameterAssert(handler);
    _handler = handler;
    
    __weak JFFAsyncRequestAccessToContactsLoader *weakSelf = self;
    
    JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book) {
        
        [weakSelf notifyHandlerWithResult:book error:nil];
    };
    
    JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
        
        [weakSelf notifyHandlerWithResult:nil error:error];
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

- (BOOL)isForeignThreadResultCallback
{
    return YES;
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
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        return [JFFAsyncRequestAccessToContactsLoader new];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
