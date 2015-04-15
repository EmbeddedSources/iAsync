#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

// { @"statuses" => [tweets] }
JFFAsyncOperationBinder asyncJSONObjectToTwitterTweets();

// [users]
JFFAsyncOperationBinder asyncJSONObjectToTwitterUsers();

// {"text": "68F7CD29-8752-4D0E-A085-D7A10C2354FC", ...}
JFFAsyncOperationBinder asyncJSONObjectToDirectTweet();

JFFAsyncOperationBinder jsonObjectToTwitterUsersIds();

JFFAsyncOperationBinder twitterResponseToNSData();
