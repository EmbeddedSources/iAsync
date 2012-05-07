#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;
@protocol JNUrlConnection;

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic ) JFFURLConnectionParams* params;
@property ( nonatomic ) id< JNUrlConnection > connection;
@property ( nonatomic ) id resultContext;

@end
