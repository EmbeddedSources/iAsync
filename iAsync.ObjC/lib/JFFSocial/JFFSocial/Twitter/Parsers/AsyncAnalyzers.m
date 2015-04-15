#import "AsyncAnalyzers.h"

#import "JFFTweet.h"
#import "JFFAsyncTwitterRequest.h"

#import "NSArray+TweetsJSONParser.h"
#import "JFFTwitterAccount+TwitterJSONApiParser.h"
#import "JFFTwitterResponseError+TweetsJSONParser.h"
#import "JFFDirectTweetMessage+TwitterJSONApiParser.h"

static JFFAsyncOperation parseTwitterResponseError(id jsonObject, id<NSCopying> context)
{
    JFFTwitterResponseError *error = [JFFTwitterResponseError newTwitterResponseErrorWithTwitterJSONObject:jsonObject
                                                                                                   context:context];
    
    return error
    ?asyncOperationWithError(error)
    :asyncOperationWithResult(jsonObject);
}

JFFAsyncOperationBinder asyncJSONObjectToTwitterTweets()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSArray *result) {
        
        NSDictionary *jsonObject = result[0];
        id<NSCopying> context    = result[1];
        
        JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
            
            NSArray *tweets = [NSArray newTweetsWithJSONObject:jsonObject error:outError];
            NSArray *accounts = [tweets map:^id(JFFTweet *tweet) {
                return tweet.user;
            }];
            return accounts;
        };
        
        JFFAsyncOperation loader = asyncOperationWithSyncOperation(loadDataBlock);
        return sequenceOfAsyncOperations(parseTwitterResponseError(jsonObject, context), loader, nil);
    };
    
    return parser;
}

JFFAsyncOperationBinder asyncJSONObjectToTwitterUsers()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSArray *result) {
        
        NSArray      *jsonObject = result[0];
        id<NSCopying> context    = result[1];
        
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
            } outError:outError];
            return accounts;
        };
        
        JFFAsyncOperation loader = asyncOperationWithSyncOperation(loadDataBlock);
        return sequenceOfAsyncOperations(parseTwitterResponseError(jsonObject, context), loader, nil);
    };
    
    return parser;
}

JFFAsyncOperationBinder asyncJSONObjectToDirectTweet()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSArray *result) {
        
        NSDictionary *jsonObject = result[0];
        id<NSCopying> context    = result[1];
        
        JFFSyncOperation loadDataBlock = ^id(NSError **error) {
            
            id accounts =  [JFFDirectTweetMessage newDirectTweetMessageWithTwitterJSONObject:jsonObject
                                                                                       error:error];
            return accounts;
        };
        
        JFFAsyncOperation loader = asyncOperationWithSyncOperation(loadDataBlock);
        return sequenceOfAsyncOperations(parseTwitterResponseError(jsonObject, context), loader, nil);
    };
    
    return parser;
}

JFFAsyncOperationBinder jsonObjectToTwitterUsersIds()
{
    JFFAsyncOperationBinder result = ^JFFAsyncOperation(NSArray *result) {
        
        NSDictionary *jsonObject = result[0];
        id<NSCopying> context    = result[1];
        
        JFFSyncOperation loadDataBlock = ^id(NSError *__autoreleasing *error) {
            
            id jsonPattern = @{
            @"ids" : @[[NSNumber class]],
            };
            
            BOOL result = [JFFJsonObjectValidator validateJsonObject:jsonObject
                                                     withJsonPattern:jsonPattern
                                                               error:error];
            return result?jsonObject[@"ids"]:nil;
        };
        
        JFFAsyncOperation loader = asyncOperationWithSyncOperation(loadDataBlock);
        return sequenceOfAsyncOperations(parseTwitterResponseError(jsonObject, context), loader, nil);
    };
    
    return result;
}

JFFAsyncOperationBinder twitterResponseToNSData()
{
    JFFAsyncOperationBinder result = ^JFFAsyncOperation(JFFTwitterResponse *response) {
        
        NSCAssert(response, @"response can not be nil");
        //TODO process JFFTwitterResponse fields if valid
        return asyncOperationWithResult(response.responseData);
    };
    
    return result;
}
