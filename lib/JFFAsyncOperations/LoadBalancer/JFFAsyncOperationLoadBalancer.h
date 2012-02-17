#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

void setBalancerActiveContextName( NSString* context_name_ );

//dont balance the same loader twice
JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation loader_ );
