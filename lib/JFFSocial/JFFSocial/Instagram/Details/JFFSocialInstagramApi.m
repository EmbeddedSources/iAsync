#import "JFFSocialInstagramApi.h"

#import <JFFUI/Extensions/UIApplication+OpenApplicationAsyncOp.h>

JFFAsyncOperation codeURLLoader(NSString *redirectURI,
                                NSString *clientId
                                )
{
    assert([clientId    length]>0);
    assert([redirectURI length]>0);

    UIApplication *application = [UIApplication sharedApplication];

    NSDictionary *params = @{
    @"redirect_uri"  : redirectURI,
    @"client_id"     : clientId   ,
    @"response_type" : @"code"    ,
    @"scope"         : @"comments",//Scope (Permissions)
    };

    static NSString *const urlFormat = @"https://instagram.com/oauth/authorize/?%@";

    NSString *urlString = [[NSString alloc] initWithFormat:urlFormat, [params stringFromQueryComponents]];

    NSURL *url = [urlString toURL];
    JFFAsyncOperation loader = [application asyncOperationWithApplicationURL:url];

    return loader;
}

JFFAsyncOperation authedUserDataLoader(NSString *redirectURI,
                                       NSString *clientId,
                                       NSString *clientSecret,
                                       NSString *code
                                       )
{
    assert([redirectURI  length]>0);
    assert([clientId     length]>0);
    assert([clientSecret length]>0);
    assert([code         length]>0);
    
    NSDictionary *params = @{
    @"client_id"     : clientId             ,
    @"client_secret" : clientSecret         ,
    @"grant_type"    : @"authorization_code",
    @"redirect_uri"  : redirectURI          ,
    @"code"          : code                 ,
    };
    
    static NSString *const urlString = @"https://api.instagram.com/oauth/access_token";
    NSURL *url = [urlString toURL];
    
    NSData *data = [params dataFromQueryComponents];
    JFFAsyncOperation loader = perkyDataURLResponseLoader(url, data, nil);
    
    return loader;
}

JFFAsyncOperation userDataLoader(NSString *userID,
                                 NSString *accessToken
                                 )
{
    assert([userID      length]>0);
    assert([accessToken length]>0);
    
    NSDictionary *params = @{
    @"access_token" : accessToken,
    };
    
    static NSString *const urlStringFormat = @"https://api.instagram.com/v1/users/%@/?%@";
    NSString *const urlString = [[NSString alloc] initWithFormat:urlStringFormat,
                                 userID,
                                 [params stringFromQueryComponents]];
    NSURL *url = [urlString toURL];
    
    JFFAsyncOperation loader = perkyDataURLResponseLoader(url, nil, nil);
    
    return loader;
}

JFFAsyncOperation followersJSONDataLoader(NSString *userID,
                                          NSString *accessToken
                                          )
{
    assert([userID      length]>0);
    assert([accessToken length]>0);
    
    NSDictionary *params = @{
    @"access_token" : accessToken,
    };
    
    static NSString *const urlStringFormat = @"https://api.instagram.com/v1/users/%@/followed-by?%@";
    NSString *const urlString = [[NSString alloc]initWithFormat:urlStringFormat, userID, [params stringFromQueryComponents]];
    NSURL *url = [urlString toURL];
    
    JFFAsyncOperation loader = perkyDataURLResponseLoader(url, nil, nil);
    
    return loader;
}

JFFAsyncOperation mediaItemsDataLoader(NSString *userID,
                                       NSString *accessToken
                                       )
{
    assert([userID      length]>0);
    assert([accessToken length]>0);
    
    NSDictionary *params = @{
    @"access_token" : accessToken,
    };
    
    static NSString *const urlStringFormat = @"https://api.instagram.com/v1/users/%@/media/recent?%@";
    NSString *const urlString = [[NSString alloc] initWithFormat:urlStringFormat, userID, [params stringFromQueryComponents]];
    NSURL *url = [urlString toURL];
    
    JFFAsyncOperation loader = perkyDataURLResponseLoader(url, nil, nil);
    
    return loader;
}

//https://api.instagram.com/v1/media/555/comments?access_token=220778258.f59def8.5b8bcbe1f1b34cbcbad8470719feb721
JFFAsyncOperation commentMediaItemDataLoader(NSString *mediaItemId,
                                             NSString *comment,
                                             NSString *accessToken)
{
    assert([mediaItemId length]>0);
    assert([comment     length]>0);
    assert([accessToken length]>0);
    
    NSDictionary *params = @{
    @"access_token" : accessToken,
    @"text"         : comment    ,
    };
    
    static NSString *const urlStringFormat = @"https://api.instagram.com/v1/media/%@/comments";
    NSString *const urlString = [[NSString alloc] initWithFormat:urlStringFormat, mediaItemId];
    NSURL *url = [urlString toURL];
    
    NSData *data = [params dataFromQueryComponents];
    JFFAsyncOperation loader = perkyDataURLResponseLoader(url, data, nil);
    
    return loader;
}
