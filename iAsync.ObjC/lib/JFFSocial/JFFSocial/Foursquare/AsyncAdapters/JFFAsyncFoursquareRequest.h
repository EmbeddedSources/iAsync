#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

JFFAsyncOperation jffFoursquareRequestLoader(NSString *requestURL, NSString *httpMethod, NSString *accessToken, NSDictionary *parameters);

JFFAsyncOperation jffFoursquareRequestLoaderWithHTTPBody (NSString *requestURL, NSMutableData *httpBody, NSString *accessToken);
