#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncOperationInterface < NSObject >

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_;

-(void)cancel:( BOOL )canceled_;

@end

JFFAsyncOperation buildAsyncOperationWithInterface( id< JFFAsyncOperationInterface > object_ );
