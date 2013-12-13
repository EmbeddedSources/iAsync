#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncRequestAccessToContactsLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncRequestAccessToContactsLoader
{
    JFFDidFinishAsyncOperationCallback _finishCallback;
}

- (void)notifyHandlerWithResult:(id)result error:(NSError *)error
{
    _finishCallback(result, error);
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    NSParameterAssert(finishCallback);
    _finishCallback = finishCallback;
    
    __weak JFFAsyncRequestAccessToContactsLoader *weakSelf = self;
    
    JFFAddressBookSuccessCallback onSuccess = ^void(JFFAddressBook *book) {
        
        [weakSelf notifyHandlerWithResult:book error:nil];
    };
    
    JFFAddressBookErrorCallback onFailure = ^void(ABAuthorizationStatus status, NSError *error) {
        
        [weakSelf notifyHandlerWithResult:nil error:error];
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
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
