#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFAsyncOperationInterfaceHandler)( id, NSError* );
typedef void (^JFFAsyncOperationInterfaceProgressHandler)( id );

@protocol JFFAsyncOperationInterface < NSObject >

-(void)asyncOperationWithResultHandler:( JFFAsyncOperationInterfaceHandler )handler_
                       progressHandler:( JFFAsyncOperationInterfaceProgressHandler )progress_;

-(void)cancel:( BOOL )canceled_;

@end
