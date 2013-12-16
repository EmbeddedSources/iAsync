#import "JFFInstagramJSONDataAnalyzers.h"

#import "JFFInstagramComment.h"
#import "JFFInstagramMediaItem.h"
#import "JFFInstagramAuthedAccount.h"
#import "JFFInstagramMediaItemImage.h"

#import "JFFInstagramResponseError.h"

@implementation JFFInstagramAccount (JFFInstagramJSONDataAnalyzers)

+ (instancetype)newInstagramAccountWithJSONObject:(NSDictionary *)userJsonObject
                                            error:(NSError **)outError
{
    id jsonPattern = @{
    @"username"        : [NSString class],
    @"profile_picture" : [NSString class],
    @"id"              : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:userJsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFInstagramAccount *result = [self new];
    
    if (result) {
        
        result.name               =  userJsonObject[@"username"];
        result.avatarURL          = [userJsonObject[@"profile_picture"] toURL];
        result.instagramAccountId =  userJsonObject[@"id"];
    }
    
    return result;
}

@end

@implementation JFFInstagramAuthedAccount (JFFInstagramJSONDataAnalyzers)

+ (instancetype)newInstagramAuthedAccountWithJSONObject:(NSDictionary *)jsonObject
                                                  error:(NSError **)outError
{
    id jsonPattern = @{
    @"user"         : [NSDictionary class],
    @"access_token" : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFInstagramAuthedAccount *result = [self newInstagramAccountWithJSONObject:jsonObject[@"user"]
                                                                          error:outError];
    
    if (!result)
        return nil;
    
    result.instagramAccessToken = jsonObject[@"access_token"];
    
    return result;
}

@end

@implementation JFFInstagramMediaItemImage (JFFInstagramJSONDataAnalyzers)

+ (instancetype)newInstagramMediaItemImageWithJsonObject:(NSDictionary *)jsonObject
                                                   error:(NSError **)outError
{
    id jsonPattern =
    @{
    @"height" : [NSNumber class],
    @"width"  : [NSNumber class],
    @"url"    : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFInstagramMediaItemImage *result = [self new];
    
    if (result) {
        result.size = CGSizeMake([jsonObject[@"width" ] floatValue],
                                 [jsonObject[@"height"] floatValue]);
        result.url  = [[NSURL alloc] initWithString:jsonObject[@"url"]];
    }
    
    return result;
}

@end

@implementation JFFInstagramMediaItem (JFFInstagramJSONDataAnalyzers)

+ (instancetype)newInstagramMediaItemWithJSONObject:(NSDictionary *)jsonObject
                                              error:(NSError **)outError
{
    id jsonPattern = @{
    @"user"   : [NSDictionary class],
    @"id"     : [NSString class],
    @"type"   : @"image",
    @"images" :
    @{
        @"low_resolution"      : [NSDictionary class],
        @"standard_resolution" : [NSDictionary class],
        @"thumbnail"           : [NSDictionary class],
    }
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFInstagramAccount *user = [JFFInstagramAccount newInstagramAccountWithJSONObject:jsonObject[@"user"]
                                                                                 error:outError];
    
    if (!user)
        return nil;
    
    NSDictionary *imagesJsonObjects = jsonObject[@"images"];
    
    JFFDictMappingWithErrorBlock mapBlock = ^(id key, id object, NSError **outError) {
        return [JFFInstagramMediaItemImage newInstagramMediaItemImageWithJsonObject:object
                                                                              error:outError];
    };
    NSDictionary *images = [imagesJsonObjects map:mapBlock
                                            error:outError];
    
    if (!images)
        return nil;
    
    JFFInstagramMediaItem *result = [self new];
    
    if (result) {
        result.mediaItemId = jsonObject[@"id"];
        result.user        = user;
        result.images      = images;
    }
    
    return result;
}

@end

@implementation JFFInstagramComment (JFFInstagramJSONDataAnalyzers)

+ (instancetype)newInstagramCommentWithJSONObject:(NSDictionary *)jsonObject
                                            error:(NSError **)outError
{
    id jsonPattern = @{
    @"from" : [NSDictionary class],
    @"text" : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFInstagramAccount *from = [JFFInstagramAccount newInstagramAccountWithJSONObject:jsonObject[@"from"]
                                                                                 error:outError];
    
    if (!from)
        return nil;
    
    JFFInstagramComment *result = [self new];
    
    if (result)
    {
        result.text = jsonObject[@"text"];
        result.from = from;
    }
    
    return result;
}

@end

static NSError *validateJSONAuthedAccountObjectOnError(NSDictionary *jsonObject)
{
    NSNumber *errorCode = jsonObject[@"code"];
    
    if (errorCode) {
        JFFInstagramResponseError *error = [JFFInstagramResponseError new];
        error.errorCode    = [errorCode unsignedIntegerValue];
        error.errorType    = jsonObject[@"error_type"   ];
        error.errorMessage = jsonObject[@"error_message"];
        return error;
    }
    
    return nil;
}

static BOOL validJeneralJSONObject(NSDictionary *jsonObject, NSError *__autoreleasing *outError)
{
    id jsonPattern = @{
    @"meta" : @{@"code" : @(200)},
    @"data" : [NSObject class],
    };
    
    return [JFFJsonObjectValidator validateJsonObject:jsonObject
                                      withJsonPattern:jsonPattern
                                                error:outError];
}

static JFFAsyncOperationBinder generalJsonDataBinderWithAnalyzer(JFFAnalyzer analyzer)
{
    NSCParameterAssert(analyzer);
    analyzer = [analyzer copy];
    
    return ^JFFAsyncOperation(NSData *data) {
        JFFAsyncOperation loader = asyncOperationBinderJsonDataParser()(data);
        
        JFFAsyncOperationBinder jsonToAccountBinder = ^JFFAsyncOperation(id jsonObject) {
            NSError *error;
            
            id result = analyzer(jsonObject, &error);
            
            if (error) {
                return asyncOperationWithError(error);
            }
            
            return asyncOperationWithResult(result);
        };
        
        return bindSequenceOfAsyncOperations(loader, jsonToAccountBinder, nil);
    };
}

JFFAsyncOperationBinder jsonDataToAuthedAccountBinder()
{
    return generalJsonDataBinderWithAnalyzer(^id(NSDictionary *jsonObject, NSError **outError) {
        NSError *error = validateJSONAuthedAccountObjectOnError(jsonObject);
        
        if (error) {
            if (outError) {
                *outError = error;
            }
            return nil;
        }
        
        JFFInstagramAuthedAccount *result = [JFFInstagramAuthedAccount newInstagramAuthedAccountWithJSONObject:jsonObject
                                                                                                         error:outError];
        
        return result;
    });
}

JFFAsyncOperationBinder jsonDataToOneAccountBinder()
{
    return generalJsonDataBinderWithAnalyzer(^id(NSDictionary *jsonObject, NSError **outError) {
        if (!validJeneralJSONObject(jsonObject, outError)) {
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
    return generalJsonDataBinderWithAnalyzer(^id(NSDictionary *jsonObject, NSError **outError) {
        if (!validJeneralJSONObject(jsonObject, outError)) {
            return nil;
        }
        
        NSArray *accountsJson = jsonObject[@"data"];
        
        NSArray *result = [accountsJson map:^id(id object, NSError *__autoreleasing *outError) {
            return [JFFInstagramAccount newInstagramAccountWithJSONObject:object
                                                                    error:outError];
        } error:outError];

        return result;
    });
}

JFFAsyncOperationBinder jsonDataToMediaItems()
{
    return generalJsonDataBinderWithAnalyzer(^id(NSDictionary *jsonObject, NSError **outError) {
        if (!validJeneralJSONObject(jsonObject, outError)) {
            return nil;
        }
        
        NSArray *mediaItemsJson = jsonObject[@"data"];
        
        NSArray *result = [mediaItemsJson map:^id(id object, NSError *__autoreleasing *outError) {
            return [JFFInstagramMediaItem newInstagramMediaItemWithJSONObject:object
                                                                        error:outError];
        } error:outError];
        
        return result;
    });
}

JFFAsyncOperationBinder jsonDataToComment()
{
    return generalJsonDataBinderWithAnalyzer(^id(NSDictionary *jsonObject, NSError **outError) {
        if (!validJeneralJSONObject(jsonObject, outError)) {
            return nil;
        }
        
        NSDictionary *commentJson = jsonObject[@"data"];
        
        id result = [JFFInstagramComment newInstagramCommentWithJSONObject:commentJson
                                                                     error:outError];
        
        return result;
    });
}
