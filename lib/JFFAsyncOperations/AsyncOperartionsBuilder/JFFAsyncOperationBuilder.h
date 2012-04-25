#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFAsyncOperationInterfaceHandler)( id, NSError* );

@protocol JFFAsyncOperationInterface < NSObject >

-(void)asyncOperationWithResultHandler:( JFFAsyncOperationInterfaceHandler )handler_
                       progressHandler:( void (^)( id ) )progress_;

-(void)cancel:( BOOL )canceled_;

@end

JFFAsyncOperation buildAsyncOperationWithInterface( id< JFFAsyncOperationInterface > object_ );
