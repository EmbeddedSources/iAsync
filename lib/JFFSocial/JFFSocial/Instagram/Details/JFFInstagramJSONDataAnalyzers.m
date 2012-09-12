#import "JFFInstagramJSONDataAnalyzers.h"

#import "JFFInstagramComment.h"
#import "JFFInstagramMediaItem.h"
#import "JFFInstagramAuthedAccount.h"

#import "JFFInstagramResponseError.h"
#import "JFFInstagramUsersListResponseError.h"

#import "JFFSocialAsyncUtils.h"

@implementation JFFInstagramAccount (JFFInstagramJSONDataAnalyzers)

+ (id)newInstagramAccountWithJSONObject:(NSDictionary *)userJsonObject
                                  error:(NSError **)error
{
    JFFInstagramAccount *result = [self new];

    result.name               =  userJsonObject[@"username"];
    result.avatarURL          = [userJsonObject[@"profile_picture"]toURL];
    result.instagramAccountId =  userJsonObject[@"id"];

    return result;
}

@end

@implementation JFFInstagramAuthedAccount (JFFInstagramJSONDataAnalyzers)

+ (id)newInstagramAuthedAccountWithJSONObject:(NSDictionary *)jsonObject
                                        error:(NSError **)error
{
    NSDictionary *userJsonObject = jsonObject[@"user"];

    JFFInstagramAuthedAccount *result = [self newInstagramAccountWithJSONObject:userJsonObject
                                                                          error:error];

    if (!result)
        return nil;

    result.instagramAccessToken = jsonObject[@"access_token"];

    return result;
}

@end

@implementation JFFInstagramMediaItem (JFFInstagramJSONDataAnalyzers)

+ (id)newInstagramMediaItemWithJSONObject:(NSDictionary *)jsonObject
                                    error:(NSError **)error
{
    JFFInstagramAccount *user = [JFFInstagramAccount newInstagramAccountWithJSONObject:jsonObject[@"user"]
                                                                                 error:error];

    if (!user)
        return nil;

    JFFInstagramMediaItem *result = [self new];

    result.mediaItemId = jsonObject[@"id"];
    result.user        = user;

    return result;
}

@end

@implementation JFFInstagramComment (JFFInstagramJSONDataAnalyzers)

+ (id)newInstagramCommentWithJSONObject:(NSDictionary *)jsonObject
                                  error:(NSError **)error
{
    JFFInstagramAccount *from = [JFFInstagramAccount newInstagramAccountWithJSONObject:jsonObject[@"user"]
                                                                                 error:error];

    if (!from)
        return nil;

    JFFInstagramComment *result = [self new];

    result.text = jsonObject[@"text"];
    result.from = from;

    return result;
}

@end

static NSError *validateJSONAuthedAccountObjectOnError(NSDictionary *jsonObject)
{
    NSNumber *errorCode = jsonObject[@"code"];

    if (errorCode)
    {
        JFFInstagramResponseError *error = [JFFInstagramResponseError new];
        error.errorCode    = [errorCode unsignedIntegerValue];
        error.errorType    = jsonObject[@"error_type"   ];
        error.errorMessage = jsonObject[@"error_message"];
        return error;
    }

    return nil;
}

static NSError *validateJeneralJSONObjectOnError(NSDictionary *jsonObject)
{
    NSNumber *errorCode = jsonObject[@"meta"][@"code"];

    if ([errorCode unsignedIntegerValue] != 200)
    {
        JFFInstagramUsersListResponseError *error = [JFFInstagramUsersListResponseError new];
        error.jsonObject = jsonObject;
        return error;
    }

    return nil;
}

static JFFAsyncOperationBinder generalJsonDataBinderWithAnalizer(JFFAnalyzer analyzer)
{
    assert(analyzer);
    analyzer = [analyzer copy];

    return ^JFFAsyncOperation(NSData *data)
    {
        JFFAsyncOperation loader = asyncJsonDataAnalizer()(data);

        JFFAsyncOperationBinder jsonToAccountBinder = ^JFFAsyncOperation(id jsonObject)
        {
            NSError *error;

            id result = analyzer(jsonObject, &error);

            if (error)
            {
                return asyncOperationWithError(error);
            }

            return asyncOperationWithResult(result);
        };
        
        return bindSequenceOfAsyncOperations(loader, jsonToAccountBinder, nil);
    };
}

JFFAsyncOperationBinder jsonDataToAuthedAccountBinder()
{
    return generalJsonDataBinderWithAnalizer(^id(NSDictionary *jsonObject, NSError **outError)
    {
        NSError *error = validateJSONAuthedAccountObjectOnError(jsonObject);

        if (error)
        {
            [error setToPointer:outError];
            return nil;
        }

        JFFInstagramAuthedAccount *result = [JFFInstagramAuthedAccount newInstagramAuthedAccountWithJSONObject:jsonObject
                                                                                                         error:outError];

        return result;
    });
}

JFFAsyncOperationBinder jsonDataToOneAccountBinder()
{
    return generalJsonDataBinderWithAnalizer(^id(NSDictionary *jsonObject, NSError **outError)
    {
        NSError *error = validateJeneralJSONObjectOnError(jsonObject);

        if (error)
        {
            [error setToPointer:outError];
            return nil;
        }

        NSDictionary *accountJson = jsonObject[@"data"];

        id result = [JFFInstagramAccount newInstagramAccountWithJSONObject:accountJson
                                                                     error:outError];

        return result;
    });
}

JFFAsyncOperationBinder jsonDataToAccountsBinder()
{
    return generalJsonDataBinderWithAnalizer(^id(NSDictionary *jsonObject, NSError **outError)
    {
        NSError *error = validateJeneralJSONObjectOnError(jsonObject);

        if (error)
        {
            [error setToPointer:outError];
            return nil;
        }

        NSArray *accountsJson = jsonObject[@"data"];
        
        NSArray *result = [accountsJson map:^id(id object, NSError *__autoreleasing *outError)
        {
            return [JFFInstagramAccount newInstagramAccountWithJSONObject:object
                                                                    error:outError];
        } error:outError];

        return result;
    });
}

JFFAsyncOperationBinder jsonDataToMediaItems()
{
    return generalJsonDataBinderWithAnalizer(^id(NSDictionary *jsonObject, NSError **outError)
    {
        NSError *error = validateJeneralJSONObjectOnError(jsonObject);

        if (error)
        {
            [error setToPointer:outError];
            return nil;
        }

        NSArray *mediaItemsJson = jsonObject[@"data"];

        NSArray *result = [mediaItemsJson map:^id(id object, NSError *__autoreleasing *outError)
        {
            return [JFFInstagramMediaItem newInstagramMediaItemWithJSONObject:object
                                                                        error:outError];
        } error:outError];

        return result;
    });
}

JFFAsyncOperationBinder jsonDataToComment()
{
    return generalJsonDataBinderWithAnalizer(^id(NSDictionary *jsonObject, NSError **outError)
    {
        NSError *error = validateJeneralJSONObjectOnError(jsonObject);

        if (error)
        {
            [error setToPointer:outError];
            return nil;
        }

        NSDictionary *commentJson = jsonObject[@"data"];

        id result = [JFFInstagramComment newInstagramCommentWithJSONObject:commentJson
                                                                     error:outError];

        return result;
    });
}
