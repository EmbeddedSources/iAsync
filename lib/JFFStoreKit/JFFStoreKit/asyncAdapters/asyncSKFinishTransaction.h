#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class SKPaymentTransaction;

//returns - transaction ids array
JFFAsyncOperation asyncOperationFinishTransaction(SKPaymentTransaction *transaction);

//returns - transaction ids array
JFFAsyncOperation asyncOperationFinishTransactions(NSArray *transactionIDs);

//returns - transaction ids array
JFFAsyncOperation asyncOperationFinishTransactionsForProducts(NSArray *productIDs);
