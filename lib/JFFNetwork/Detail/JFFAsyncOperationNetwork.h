#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;
@protocol JNUrlConnection;

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, retain ) JFFURLConnectionParams* params;
@property ( nonatomic, retain ) id< JNUrlConnection > connection;
@property ( nonatomic, retain ) id resultContext;

@end
