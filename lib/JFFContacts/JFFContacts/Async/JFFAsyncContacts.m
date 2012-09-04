#import "JFFAsyncContacts.h"

#import "JFFContact.h"
#import "JFFAddressBookFactory.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFAsyncAllContactsLoader : NSObject < JFFAsyncOperationInterface >
@end

@implementation JFFAsyncAllContactsLoader

-(void)asyncOperationWithResultHandler:( JFFAsyncOperationInterfaceHandler )handler_
                       progressHandler:( JFFAsyncOperationInterfaceProgressHandler )progress_
{
    handler_  = [ handler_ copy ];
    progress_ = [ progress_ copy ];

    JFFAddressBookSuccessCallback onSuccess_ = ^( JFFAddressBook* book_ )
    {
        NSArray* result_ = [ JFFContact allContactsAddressBook: book_ ];

        if ( progress_ )
            progress_( result_ );

        if ( handler_ )
            handler_( result_, nil );
    };

    JFFAddressBookErrorCallback onFailure_ = ^( ABAuthorizationStatus status_, NSError* error_ )
    {
        if ( handler_ )
            handler_( nil, error_ );
    };

    [ JFFAddressBookFactory asyncAddressBookWithSuccessBlock: onSuccess_
                                               errorCallback: onFailure_ ];
}

-(void)cancel:( BOOL )canceled_
{
}

@end

JFFAsyncOperation asyncAllContactsLoader( void )
{
    return buildAsyncOperationWithInterface( [ JFFAsyncAllContactsLoader new ] );
}
