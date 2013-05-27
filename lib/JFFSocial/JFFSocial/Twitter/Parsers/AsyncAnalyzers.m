#import "AsyncAnalyzers.h"

#import "JFFTweet.h"
#import "JFFAsyncTwitterRequest.h"

#import "NSArray+TweetsJSONParser.h"
#import "JFFTwitterAccount+TwitterJSONApiParser.h"
#import "JFFDirectTweetMessage+TwitterJSONApiParser.h"

JFFAsyncOperationBinder asyncJSONObjectToTwitterTweets()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSDictionary *jsonObject) {
        
        JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
            
            NSArray *tweets = [NSArray newTweetsWithJSONObject:jsonObject error:outError];
            NSArray *accounts = [tweets map:^id(JFFTweet *tweet) {
                return tweet.user;
            }];
            return accounts;
        };
        return asyncOperationWithSyncOperation(loadDataBlock);
    };
    
    return parser;
}

JFFAsyncOperationBinder asyncJSONObjectToTwitterUsers()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSArray *jsonObject) {
        
        NSError *error;
        if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                        withJsonPattern:[NSArray class]
                                                  error:&error]) {
            
            return asyncOperationWithError(error);
        }
        
        JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
            NSArray *accounts = [jsonObject map:^id(id object, NSError *__autoreleasing *outError) {
                return [JFFTwitterAccount newTwitterAccountWithTwitterJSONApiDictionary:object
                                                                                  error:outError];
            } error:outError];
            return accounts;
        };
        return asyncOperationWithSyncOperation(loadDataBlock);
    };
    
    return parser;
}

JFFAsyncOperationBinder asyncJSONObjectToDirectTweet()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSDictionary *jsonObject) {
        JFFSyncOperation loadDataBlock = ^id(NSError **error) {
            
            id accounts =  [JFFDirectTweetMessage newDirectTweetMessageWithTwitterJSONObject:jsonObject
                                                                                       error:error];
            return accounts;
        };
        return asyncOperationWithSyncOperation(loadDataBlock);
    };
    
    return parser;
}

JFFAsyncOperationBinder jsonObjectToTwitterUsersIds()
{
    JFFAsyncOperationBinder result = ^JFFAsyncOperation(NSDictionary *jsonObject) {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *error) {
            id jsonPattern = @{
            @"ids" : @[[NSNumber class]],
            };
            
            BOOL result = [JFFJsonObjectValidator validateJsonObject:jsonObject
                                                     withJsonPattern:jsonPattern
                                                               error:error];
            return result?jsonObject[@"ids"]:nil;
        });
    };
    
    return result;
}

JFFAsyncOperationBinder twitterResponseToNSData()
{
    JFFAsyncOperationBinder result = ^JFFAsyncOperation(JFFTwitterResponse *response) {
        assert(response);
        //TODO process JFFTwitterResponse fields if valid
        return asyncOperationWithResult(response.responseData);
    };
    
    return result;
}
