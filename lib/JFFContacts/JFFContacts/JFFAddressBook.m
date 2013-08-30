#import "JFFAddressBook.h"

#import <AddressBook/AddressBook.h>

@implementation JFFAddressBook
{
    ABAddressBookRef _rawBook;
}

- (void)dealloc
{
    CFRelease(_rawBook);
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithRawBook:(ABAddressBookRef)rawBook
{
    NSParameterAssert(NULL != rawBook);
    
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _rawBook = rawBook;
    
    return self;
}

- (BOOL)removeAllContactsWithError:(NSError **)error
{
    ABAddressBookRef rawBook = self.rawBook;
    CFErrorRef rawError = NULL;
    NSArray *contacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(rawBook);
    
    for (id record in contacts)
    {
        ABRecordRef rawRecord = (__bridge ABRecordRef)record;
        ABAddressBookRemoveRecord(rawBook, rawRecord, &rawError);
        if (NULL != rawError) {
            [(__bridge NSError *)rawError setToPointer:error];
            return NO;
        }
    }
    
    ABAddressBookSave( rawBook, &rawError );
    if (NULL != rawError) {
        [(__bridge NSError *)rawError setToPointer:error];
        return NO;
    }
    
    return YES;
}

@end
