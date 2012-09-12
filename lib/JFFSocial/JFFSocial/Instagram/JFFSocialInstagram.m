#import "JFFSocialInstagram.h"

#import "JFFInstagramMediaItem.h"
#import "JFFInstagramAuthedAccount.h"

#import "JFFSocialAsyncUtils.h"
#import "JFFInstagramResponseError.h"
#import "JFFInvalidInstagramResponseURLError.h"

#import "JFFSocialInstagramApi.h"

#import "JFFInstagramJSONDataAnalyzers.h"

@implementation JFFSocialInstagram

+ (JFFAsyncOperation)userLoaderForForUserId:(NSString *)userId
                                accessToken:(NSString *)accessToken
{
    JFFAsyncOperation loader = userDataLoader(userId, accessToken);

    return bindSequenceOfAsyncOperations(loader, jsonDataToOneAccountBinder(), nil);
}

+ (JFFAsyncOperation)authedUserLoaderWithClientId:(NSString *)clientId
                                     clientSecret:(NSString *)clientSecret
                                      redirectURI:(NSString *)redirectURI
{
    JFFAsyncOperation oAuthUrlLoader = codeURLLoader(redirectURI, clientId);

    JFFAsyncOperationBinder urlToCodeBinder = ^JFFAsyncOperation(NSURL *url)
    {
        NSDictionary *params = [[url query]dictionaryFromQueryComponents];
        NSArray* codeParams = params[@"code"];

        if ([codeParams count]==0)
        {
            JFFInvalidInstagramResponseURLError *error = [JFFInvalidInstagramResponseURLError new];
            error.url = url;
            return asyncOperationWithError(error);
        }

        NSString *code = codeParams[0];
        return asyncOperationWithResult(code);
    };

    JFFAsyncOperationBinder userDataBinder = ^JFFAsyncOperation(NSString *code)
    {
        return authedUserDataLoader(redirectURI,
                                    clientId,
                                    clientSecret,
                                    code
                                    );
    };

    return bindSequenceOfAsyncOperations(oAuthUrlLoader,
                                         urlToCodeBinder,
                                         userDataBinder,
                                         jsonDataToAuthedAccountBinder(),
                                         nil );
}

+ (JFFAsyncOperation)followedByLoaderForUserId:(NSString *)userId
                                   accessToken:(NSString *)accessToken
{
    JFFAsyncOperation loader = followersJSONDataLoader(userId,
                                                       accessToken
                                                       );

    return bindSequenceOfAsyncOperations(loader, jsonDataToAccountsBinder(), nil);
}

+ (JFFAsyncOperation)followedByLoaderWithClientId:(NSString *)clientId
                                     clientSecret:(NSString *)clientSecret
                                      redirectURI:(NSString *)redirectURI
{
    JFFAsyncOperation userLoader = [self authedUserLoaderWithClientId:clientId
                                                         clientSecret:clientSecret
                                                          redirectURI:redirectURI];

    JFFAsyncOperationBinder userRelatedDataBinder = ^JFFAsyncOperation(JFFInstagramAuthedAccount *account)
    {
        return [self followedByLoaderForUserId:account.instagramAccountId
                                   accessToken:account.instagramAccessToken];
    };

    return bindSequenceOfAsyncOperations(userLoader,
                                         userRelatedDataBinder,
                                         nil );
}

+ (JFFAsyncOperation)recentMediaItemsLoaderForUserId:(NSString *)userId
                                         accessToken:(NSString *)accessToken
{
    JFFAsyncOperation loader = mediaItemsDataLoader(userId, accessToken);

    return bindSequenceOfAsyncOperations(loader,
                                         jsonDataToMediaItems(),
                                         nil);
}

+ (JFFAsyncOperation)commentMediaItemLoaderWithId:(NSString *)mediaItemId
                                          comment:(NSString *)comment
                                      accessToken:(NSString *)accessToken
{
    JFFAsyncOperation loader = commentMediaItemDataLoader(mediaItemId, comment, accessToken);

    return bindSequenceOfAsyncOperations(loader,
                                         jsonDataToComment(),
                                         nil);
}

+ (JFFAsyncOperation)notifyUsersFollowersWithId:(NSString *)userId
                                        message:(NSString *)message
                                    accessToken:(NSString *)accessToken
{
    JFFAsyncOperation usersLoader = [self followedByLoaderForUserId:userId
                                                        accessToken:accessToken];

    JFFAsyncOperationBinder recentMediaItemsBinder = ^JFFAsyncOperation(NSArray *accounts)
    {
        NSArray *mediaItemsLoaders = [accounts map:^id(JFFInstagramAccount *account)
        {
            return [self recentMediaItemsLoaderForUserId:account.instagramAccountId
                                             accessToken:accessToken];
        }];

        return groupOfAsyncOperationsArray(mediaItemsLoaders);
    };

    JFFAsyncOperationBinder selectFirstMediaItemsBinder = ^JFFAsyncOperation(NSArray *arrayOfArrayMediaItems)
    {
        NSArray *result = [arrayOfArrayMediaItems forceMap:^id(NSArray *mediaItems)
        {
            return [mediaItems count]>0?mediaItems[0]:nil;
        }];

        return asyncOperationWithResult(result);
    };

    JFFAsyncOperationBinder commentEachMediaItemsBinder = ^JFFAsyncOperation(NSArray *mediaItems)
    {
        NSArray *commentMediaItemsLoaders = [mediaItems map:^id(JFFInstagramMediaItem *mediaItem)
        {
            return [self commentMediaItemLoaderWithId:mediaItem.mediaItemId
                                              comment:message
                                          accessToken:accessToken];
        }];

        return groupOfAsyncOperationsArray(commentMediaItemsLoaders);
    };

    return bindSequenceOfAsyncOperations(usersLoader,
                                         recentMediaItemsBinder,
                                         selectFirstMediaItemsBinder,
                                         commentEachMediaItemsBinder,
                                         nil);
}

@end
