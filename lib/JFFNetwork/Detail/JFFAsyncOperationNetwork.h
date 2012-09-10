#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>
#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationInterface.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;
@protocol JNUrlConnection;

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property (nonatomic) JFFURLConnectionParams* params;
@property (nonatomic) id< JNUrlConnection > connection;
@property (nonatomic, copy) JFFAnalyzer responseAnalyzer;

@end
