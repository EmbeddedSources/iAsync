#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;
@protocol JNUrlConnection;

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, strong ) JFFURLConnectionParams* params;
@property ( nonatomic, strong ) id< JNUrlConnection > connection;
@property ( nonatomic, strong ) id resultContext;

@end
