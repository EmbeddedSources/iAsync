#import "JFFSocialTwitter.h"

#import "JFFAsyncTwitterRequest.h"
#import "JFFAsyncTwitterAccessRequest.h"

#import "JFFNoTwitterAccountsError.h"
#import "AsyncAnalyzers.h"

#import "JFFTwitterDirectMessageAlreadySentError.h"

#import <JFFRestKit/JFFRestKit.h>
#import <JFFRestKit/Details/JFFResponseDataWithUpdateData.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define DEFAULT_SEARCH_RADIUS 100.f

@interface JFFTwitterReponsesCache : NSObject <JFFRestKitCache>
@end

@implementation JFFTwitterReponsesCache
{
    NSCache *_cache;
}

- (NSCache *)cache
{
    if (!_cache) {
        
        _cache = [NSCache new];
    }
    
    return _cache;
}

- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                    JFFAsyncOperationChangeStateCallback stateCallback,
                                    JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFResponseDataWithUpdateData *cachedData = [JFFResponseDataWithUpdateData new];
        
        cachedData.data       = data;
        cachedData.updateDate = [NSDate new];
        
        [self.cache setObject:cachedData forKey:key];
        
        if (doneCallback)
            doneCallback([NSNull new], nil);
        
        return JFFStubHandlerAsyncOperationBlock;
    };
}

- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        if (doneCallback) {
            
            JFFResponseDataWithUpdateData *cachedData = [self.cache objectForKey:key];
            doneCallback(cachedData, cachedData?nil:[JFFSilentError newErrorWithDescription:@"no data for key"]);
        }
        
        return JFFStubHandlerAsyncOperationBlock;
    };
}

@end

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

static BOOL isAuthorized()
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

static JFFAsyncOperation twitterAccountsLoader()
{
    if (!isAuthorized()) {
        
        return asyncOperationWithError([JFFNoTwitterAccountsError new]);
    }
    
    return sequenceOfAsyncOperations(jffTwitterAccessRequestLoader(),
                                     asyncOperationWithSyncOperationInCurrentQueue(twitterAccountsGetter()),
                                     nil
                                     );
}

@implementation JFFSocialTwitter

+ (BOOL)isAuthorized
{
    return isAuthorized();
}

+ (JFFAsyncOperation)authorizationLoader
{
    return twitterAccountsLoader();
}

+ (JFFAsyncOperationBinder)dataLoaderForIdentifier
{
    return ^JFFAsyncOperation(id<NSCopying> loadDataIdentifier) {
    
        NSString *urlString           = loadDataIdentifier[@"urlString"];
        NSDictionary *parameters      = loadDataIdentifier[@"parameters"];
        SLRequestMethod requestMethod = [loadDataIdentifier[@"requestMethod"] integerValue];
        
        JFFAsyncOperationBinder requestBinder = ^JFFAsyncOperation(NSArray *accountStroreAndAccounts) {
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:requestMethod
                                                              URL:[urlString toURL]
                                                       parameters:parameters];
            
            request.account = accountStroreAndAccounts[1][0];
            
            JFFAsyncOperation requestOperation = jffTwitterRequest(request);
            
            return requestOperation;
        };
        
        JFFAsyncOperation loaderOperation = bindSequenceOfAsyncOperations(twitterAccountsLoader(),
                                                                          requestBinder,
                                                                          nil);
        
        JFFAsyncOperation loader = bindSequenceOfAsyncOperations(loaderOperation,
                                                                 twitterResponseToNSData(),
                                                                 nil);
        
        return loader;
    };
}

+ (JFFAsyncBinderForIdentifier)analyzerForDataWithAnalyzer:(JFFAsyncOperationBinder)ayncAnalyzer
{
    ayncAnalyzer = [ayncAnalyzer copy];
    
    return ^JFFAsyncOperationBinder(id<NSCopying> loadDataIdentifier) {
        
        return ^JFFAsyncOperation(NSData *data) {
            
            JFFAsyncOperation jsonBuilder = asyncOperationBinderJsonDataParser()(data);
            
            JFFAsyncOperationBinder analyzer = ^JFFAsyncOperation(id jsonObject) {
                
                return ayncAnalyzer(@[jsonObject, loadDataIdentifier]);
            };
            
            return bindSequenceOfAsyncOperations(jsonBuilder, analyzer, nil);
        };
    };
}

+ (JFFCacheKeyForIdentifier)cacheKeyForIdentifier
{
    return ^(id<NSCopying, NSObject> loadDataIdentifier) {
        
        return [loadDataIdentifier description];
    };
}

+ (id<JFFRestKitCache>)cache
{
    static id<JFFRestKitCache> result;
    
    if (!result) {
        
        result = [JFFTwitterReponsesCache new];
    }
    
    return result;
}

+ (JFFAsyncOperation)generalTwitterApiDataLoaderWithURLString:(NSString *)urlString
                                                   parameters:(NSDictionary *)parameters
                                                requestMethod:(SLRequestMethod)requestMethod
                                                 ayncAnalyzer:(JFFAsyncOperationBinder)ayncAnalyzer
                                   cacheDataLifeTimeInSeconds:(NSTimeInterval)cacheDataLifeTimeInSeconds
{
    ayncAnalyzer = [ayncAnalyzer copy];
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        id<NSCopying, NSObject> loadDataIdentifier =
        @{
          @"urlString"     : urlString,
          @"parameters"    : parameters?:@{},
          @"requestMethod" : @(requestMethod),
          };
        
        JFFAsyncOperation loader;
        
        if (cacheDataLifeTimeInSeconds == 0.) {
            
            loader = bindSequenceOfAsyncOperations([self dataLoaderForIdentifier](loadDataIdentifier),
                                                   [self analyzerForDataWithAnalyzer:ayncAnalyzer](loadDataIdentifier),
                                                   nil);
        } else {
            
            JFFSmartDataLoaderFields *args = [JFFSmartDataLoaderFields new];
            
            args.loadDataIdentifier         = loadDataIdentifier;
            args.dataLoaderForIdentifier    = [self dataLoaderForIdentifier];
            args.analyzerForData            = [self analyzerForDataWithAnalyzer:ayncAnalyzer];
            args.cacheKeyForIdentifier      = [self cacheKeyForIdentifier];
            args.cacheDataLifeTimeInSeconds = cacheDataLifeTimeInSeconds;
            args.cache                      = self.cache;
            
            loader = jSmartDataLoaderWithCache(args);
        }
        
        return loader(progressCallback,
                      stateCallback,
                      doneCallback);
    };
}

+ (JFFAsyncOperation)generalTwitterApiDataLoaderWithURLString:(NSString *)urlString
                                                   parameters:(NSDictionary *)parameters
                                                requestMethod:(SLRequestMethod)requestMethod
                                                 ayncAnalyzer:(JFFAsyncOperationBinder)ayncAnalyzer
{
    return [self generalTwitterApiDataLoaderWithURLString:urlString
                                               parameters:parameters
                                            requestMethod:requestMethod
                                             ayncAnalyzer:ayncAnalyzer
                               cacheDataLifeTimeInSeconds:0.];
}

+ (JFFAsyncOperation)usersNearbyCoordinatesLatitude:(double)latitude longitude:(double)longitude
{
    static NSString *geocodeFormat = @"%f,%f,100mi";
    
    id params = @{
    @"q"                : @"",
    @"geocode"          : [[NSString alloc] initWithFormat:geocodeFormat, latitude, longitude],
    @"count"            : @"100",
    @"include_entities" : @"true",
    @"result_type"      : @"recent",
    };
    
    return [self generalTwitterApiDataLoaderWithURLString:@"https://api.twitter.com/1.1/search/tweets.json"
                                               parameters:params
                                            requestMethod:SLRequestMethodGET
                                             ayncAnalyzer:asyncJSONObjectToTwitterTweets()];
}

+ (JFFAsyncOperation)followersLoader
{
    NSString *urlString = @"https://api.twitter.com/1.1/followers/ids.json";
    
    JFFAsyncOperation followersIds = [self generalTwitterApiDataLoaderWithURLString:urlString
                                                                         parameters:nil
                                                                      requestMethod:SLRequestMethodGET
                                                                       ayncAnalyzer:jsonObjectToTwitterUsersIds()
                                                         cacheDataLifeTimeInSeconds:10.*60.];
    
    JFFAsyncOperationBinder usersForIds = ^JFFAsyncOperation(NSArray *ids) {
        
        if ([ids count] == 0) {
            return asyncOperationWithResult(@[]);
        }
        
        ids = [ids sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            
            return [obj1 compare:obj2];
        }];
        
        id params = @{
        @"user_id" : [ids componentsJoinedByString:@","],
        };
        
        JFFAsyncOperation result = [self generalTwitterApiDataLoaderWithURLString:@"https://api.twitter.com/1.1/users/lookup.json"
                                                                       parameters:params
                                                                    requestMethod:SLRequestMethodGET
                                                                     ayncAnalyzer:asyncJSONObjectToTwitterUsers()
                                                       cacheDataLifeTimeInSeconds:10.*60.];
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
    JFFAsyncOperation loader = [self generalTwitterApiDataLoaderWithURLString:urlString
                                                                   parameters:params
                                                                requestMethod:SLRequestMethodPOST
                                                                 ayncAnalyzer:asyncJSONObjectToDirectTweet()];
    
    loader = asyncOperationWithFinishHookBlock(loader, ^(id result, NSError *error, JFFDidFinishAsyncOperationCallback doneCallback) {
        
        if ([error isKindOfClass:[JFFTwitterDirectMessageAlreadySentError class]]) {
            
            result = [NSNull new];
            error  = nil;
        }
        
        doneCallback(result, error);
    });
    
    return loader;
}

+ (JFFAsyncOperation)sendTweetMessage:(NSString *)message
{
    NSDictionary *params = @{
    @"status" : message,
    };
    
    JFFAsyncOperation result = [self generalTwitterApiDataLoaderWithURLString:@"http://api.twitter.com/1/statuses/update.json"
                                                                   parameters:params
                                                                requestMethod:SLRequestMethodPOST
                                                                 ayncAnalyzer:asyncJSONObjectToDirectTweet()];
    return result;
}

@end
