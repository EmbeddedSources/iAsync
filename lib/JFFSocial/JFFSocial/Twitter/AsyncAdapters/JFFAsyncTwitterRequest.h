#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class TWRequest;

@interface JFFTwitterResponse : NSObject

@property (nonatomic) NSData *responseData;
@property (nonatomic) NSHTTPURLResponse *urlResponse;

@end

JFFAsyncOperation jffTwitterRequest(TWRequest *request);
