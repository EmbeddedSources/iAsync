#import "JFFAddressBookFactory.h"

#import "JFFAddressBook.h"
#import "JFFAddressBookAccessError.h"

static NSError *convertErrorType(NSError *error, ABAuthorizationStatus authorizationStatus)
{
    if (!error)
        return [JFFAddressBookAccessError new];
    
    JFFAddressBookWrapperError *result = [JFFAddressBookWrapperError newAddressBookWrapperErrorWithNativeError:error];
    result.nativeError         = error;
    result.authorizationStatus = authorizationStatus;
    return result;
}

@implementation JFFAddressBookFactory

+ (void)asyncAddressBookWithOnCreatedBlock:(JFFAddressBookOnCreated)callback
{
    NSParameterAssert(callback);
    
    CFErrorRef error = NULL;
    ABAddressBookRef result = ABAddressBookCreateWithOptions(0, &error);
    ABAuthorizationStatus authorizationStatus = ::ABAddressBookGetAuthorizationStatus();
    
    if (NULL != error) {
        
        NSError *retError = (__bridge NSError *)error;
        if (result)
            CFRelease(result);
        
        if (callback)
            callback(nil, kABAuthorizationStatusNotDetermined, convertErrorType(retError, authorizationStatus));
        return;
    }
    
    JFFAddressBook *bookWrapper = [[JFFAddressBook alloc] initWithRawBook:result];
    
    if (authorizationStatus != kABAuthorizationStatusNotDetermined) {
        
        BOOL blockGranted = (authorizationStatus == kABAuthorizationStatusAuthorized);
        callback(bookWrapper, ::ABAddressBookGetAuthorizationStatus(), blockGranted?nil:convertErrorType(nil, authorizationStatus));
    }
    
    callback = [callback copy];
    
    ABAddressBookRequestAccessCompletionHandler onAddressBookAccess =
    
        ^void(bool blockGranted, CFErrorRef blockError) {
            
            NSError *retError = (__bridge NSError *)(blockError);
            ABAuthorizationStatus authorizationStatus = ::ABAddressBookGetAuthorizationStatus();
            
            dispatch_async(dispatch_get_main_queue(), ^void(void){
                callback(bookWrapper, ::ABAddressBookGetAuthorizationStatus(), blockGranted?nil:convertErrorType(retError, authorizationStatus));
            });
        };
    
    ABAddressBookRequestAccessWithCompletion(result, onAddressBookAccess);
}

+ (NSString *)bookStatusToString:(ABAuthorizationStatus)status
{
    if (status > kABAuthorizationStatusAuthorized) {
        return nil;
    }
    
    static NSArray *const errors =
    @[
        @"kABAuthorizationStatusNotDetermined",
        @"kABAuthorizationStatusRestricted"   ,
        @"kABAuthorizationStatusDenied"       ,
        @"kABAuthorizationStatusAuthorized"   ,
    ];
    
    return errors[status];
}

+ (void)asyncAddressBookWithSuccessBlock:(JFFAddressBookSuccessCallback)onSuccess
                           errorCallback:(JFFAddressBookErrorCallback)onFailure
{
    NSParameterAssert([[NSThread currentThread] isMainThread]);
    NSParameterAssert(nil!=onSuccess);
    NSParameterAssert(nil!=onFailure);
    
    onSuccess = [onSuccess copy];
    onFailure = [onFailure copy];
    
    [self asyncAddressBookWithOnCreatedBlock:
     ^void(JFFAddressBook *book, ABAuthorizationStatus status, NSError *error) {
         if (kABAuthorizationStatusAuthorized != status) {
             onFailure(status, error);
         } else {
             onSuccess(book);
         }
     }];
}

@end
