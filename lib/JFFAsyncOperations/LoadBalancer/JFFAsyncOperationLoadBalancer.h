#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

void setBalancerActiveContextName(NSString *contextName);
NSString * balancerActiveContextName (void);
NSString * balancerCurrentContextName(void);

//TODO20 immediately cancel callback

//dont balance the same loader twice
JFFAsyncOperation balancedAsyncOperation(JFFAsyncOperation loader);
JFFAsyncOperation balancedAsyncOperationInContext(JFFAsyncOperation loader, NSString *contextName);
