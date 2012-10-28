#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

void setBalancerActiveContextName(NSString *contextName);

//dont balance the same loader twice
JFFAsyncOperation balancedAsyncOperation(JFFAsyncOperation loader);
