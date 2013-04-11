#import "JFFSocialTwitter.h"

#import "JFFAsyncTwitterRequest.h"
#import "JFFAsyncTwitterAccessRequest.h"

#import "JFFAsyncTwitterCreateAccount.h"
#import "JFFNoTwitterAccountsError.h"
#import "AsyncAnalyzers.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#define DEFAULT_SEARCH_RADIUS 100.0f

static JFFSocialTwitterDidLoginCallback globalDidLoginCallback;

static JFFSyncOperation twitterAccountsGetter()
{
    return ^id(NSError **error) {
        
        ACAccountStore *accountStore = [ACAccountStore new];
        
        ACAccountType *type = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        NSArray *accounts = [accountStore accountsWithAccountType:type];
        
        if ([accounts count]>0)
            return @[accountStore, accounts];
        
        if (error)
            *error = [JFFNoTwitterAccountsError new];
        return nil;
    };
}

static JFFAsyncOperation twitterAccountsLoaderIOS5()
{
    JFFAsyncOperation accountsLoader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                                JFFCancelAsyncOperationHandler cancelCallback,
                                                                JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFSyncOperation twitterAccounts = twitterAccountsGetter();
        
        NSArray *accounts = twitterAccounts(NULL);
        
        JFFAsyncOperation loader;
        
        if ([accounts count] > 0) {
            loader = asyncOperationWithResult(accounts);
        } else {
            loader = sequenceOfAsyncOperations(jffCreateTwitterAccountLoader(),
                                               asyncOperationWithSyncOperationInCurrentQueue(twitterAccounts),
                                               nil);
        }
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler doneCallbackWp = ^(id result, NSError *error) {
            if (doneCallback)
                doneCallback(result, error);
            
            if (globalDidLoginCallback && result)
                globalDidLoginCallback(nil);
        };
        
        return loader(progressCallback, cancelCallback, doneCallbackWp);
    };
    
    return sequenceOfAsyncOperations(jffTwitterAccessRequestLoader(),
                                     accountsLoader,
                                     nil
                                     );
}

static JFFAsyncOperation twitterAccountsLoaderIOS6()
{
    if (![TWTweetComposeViewController canSendTweet]) {
        return asyncOperationWithError([JFFNoTwitterAccountsError new]);
    }
    
    return sequenceOfAsyncOperations(jffTwitterAccessRequestLoader(),
                                     asyncOperationWithSyncOperationInCurrentQueue(twitterAccountsGetter()),
                                     nil
                                     );
}

static JFFAsyncOperation twitterAccountsLoader()
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"] >= NSOrderedSame) {
        return twitterAccountsLoaderIOS6();
    }
    
    return twitterAccountsLoaderIOS5();
}

@implementation JFFSocialTwitter

+ (BOOL)isAuthorized
{
    return [TWTweetComposeViewController canSendTweet];
}

+ (JFFAsyncOperation)authorizationLoader
{
    return twitterAccountsLoader();
}

+ (JFFAsyncOperation)generalTwitterApiDataLoaderWithURLString:(NSString *)urlString
                                                   parameters:(NSDictionary *)parameters
                                                requestMethod:(TWRequestMethod)requestMethod
                                                 ayncAnalyzer:(JFFAsyncOperationBinder)ayncAnalyzer
{
    JFFAsyncOperationBinder requestBinder = ^JFFAsyncOperation(NSArray *accountStroreAndAccounts) {
        
        TWRequest *request = [[TWRequest alloc] initWithURL:[urlString toURL]
                                                 parameters:parameters
                                              requestMethod:requestMethod];
        
        request.account = accountStroreAndAccounts[1][0];
        
        JFFAsyncOperation requestOperation = jffTwitterRequest(request);
        
        return requestOperation;
    };
    
    JFFAsyncOperation loaderOperation = bindSequenceOfAsyncOperations(twitterAccountsLoader(),
                                                                      requestBinder,
                                                                      nil);
    
    return bindSequenceOfAsyncOperations(loaderOperation,
                                         twitterResponseToNSData(),
                                         asyncOperationBinderJsonDataParser(),
                                         ayncAnalyzer,
                                         nil);
}

+ (JFFAsyncOperation)usersNearbyCoordinatesLantitude:(double)lantitude longitude:(double)longitude
{
    static NSString *geocodeFormat = @"%f,%f,100mi";
    
    id params = @{
    @"q"                : @"",
    @"geocode"          : [[NSString alloc] initWithFormat:geocodeFormat, lantitude, longitude],
    @"count"            : @"100",
    @"include_entities" : @"true",
    @"result_type"      : @"recent",
    };
    
    return [self generalTwitterApiDataLoaderWithURLString:@"https://api.twitter.com/1.1/search/tweets.json"
                                               parameters:params
                                            requestMethod:TWRequestMethodGET
                                             ayncAnalyzer:asyncJSONObjectToTwitterTweets()];
}

+ (JFFAsyncOperation)followersLoader
{
    NSString *urlString = @"https://api.twitter.com/1.1/followers/ids.json";
    JFFAsyncOperation followersIds = [self generalTwitterApiDataLoaderWithURLString:urlString
                                                                         parameters:nil
                                                                      requestMethod:TWRequestMethodGET
                                                                       ayncAnalyzer:jsonObjectToTwitterUsersIds()];
    
    JFFAsyncOperationBinder usersForIds = ^JFFAsyncOperation(NSArray *ids) {
        
        if ([ids count] == 0) {
            return asyncOperationWithResult(@[]);
        }
        
        id params = @{
        @"user_id" : [ids componentsJoinedByString:@","],
        };
        
        JFFAsyncOperation result = [self generalTwitterApiDataLoaderWithURLString:@"https://api.twitter.com/1.1/users/lookup.json"
                                                                       parameters:params
                                                                    requestMethod:TWRequestMethodGET
                                                                     ayncAnalyzer:asyncJSONObjectToTwitterUsers()];
        return result;
    };

    return bindSequenceOfAsyncOperations(followersIds, usersForIds, nil);
}

+ (JFFAsyncOperation)sendDirectMessage:(NSString *)message
                      toFollowerWithId:(NSString *)userId
{
    NSDictionary *params = @{
    @"text"    : message,
    @"user_id" : userId,
    };
    
    NSString *urlString = @"https://api.twitter.com/1.1/direct_messages/new.json";
    JFFAsyncOperation result = [self generalTwitterApiDataLoaderWithURLString:urlString
                                                                   parameters:params
                                                                requestMethod:TWRequestMethodPOST
                                                                 ayncAnalyzer:asyncJSONObjectToDirectTweet()];
    return result;
}

+ (JFFAsyncOperation)sendTweetMessage:(NSString *)message
{
    NSDictionary *params = @{
    @"status" : message,
    };
    
    JFFAsyncOperation result = [self generalTwitterApiDataLoaderWithURLString:@"http://api.twitter.com/1/statuses/update.json"
                                                                   parameters:params
                                                                requestMethod:TWRequestMethodPOST
                                                                 ayncAnalyzer:asyncJSONObjectToDirectTweet()];
    return result;
}

@end
