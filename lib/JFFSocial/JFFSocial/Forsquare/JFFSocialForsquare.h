#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSocialForsquare : NSObject

+ (JFFAsyncOperation)authLoader;

+ (JFFAsyncOperation)friendsLoader;

@end
