#import "JFFFoursquareSessionStorage.h"

#import "JFFFoursquareAuthURLError.h"

#define FOURSQUARE_ACCESS_TOKEN_KEY @"FOURSQUARE_ACCESS_TOKEN_KEY"
#define FOURSQUARE_AUTH_URL_FORMAT @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@"

//#define FOURSQUARE_CLIENT_ID @"XKMEL2NCDJOA2HKMVBRPMCWGFOGQ1D0ETASNLKBOTAMVQLO1"

//Test app
//#define FOURSQUARE_CLIENT_ID @"232CV0MLCCG5BCJD1FIKRPOXI4TFFHIFXX25QN0F0IM5YPFB"
//#define FOURSQUARE_REDIRECT_URI @"fq111://authorize"

//Live app
#define FOURSQUARE_CLIENT_ID @"2FYZ0AMUZV42YOTVLDINVQF21HHBVTVKWEH3A0QMGUEXW1ZC"
#define FOURSQUARE_REDIRECT_URI @"fqWishdates://authorize"


@interface JFFFoursquareSessionStorage ()

@property (copy, nonatomic) JFFDidFinishAsyncOperationHandler authorizeHendler;

@end



@implementation JFFFoursquareSessionStorage

#pragma mark - Singletone

+ (id)shared
{
    static JFFFoursquareSessionStorage *_sharedFoursquareSessionStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFoursquareSessionStorage = [self new];
    });
    return _sharedFoursquareSessionStorage;
}

#pragma mark - Constants accessors

+ (NSString *)redirectURI
{
    return FOURSQUARE_REDIRECT_URI;
}

#pragma mark - Saving of token

+ (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:FOURSQUARE_ACCESS_TOKEN_KEY];
}


+ (void)saveAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:FOURSQUARE_ACCESS_TOKEN_KEY];
}

#pragma mark - Authorization

- (void)openSessionWithHandler:(JFFDidFinishAsyncOperationHandler)hendler
{
    self.authorizeHendler = hendler;
    
    NSURL *authURL = [[[self class] authURLString]toURL];
    
    if ([[UIApplication sharedApplication] canOpenURL:authURL])
    {
        [[UIApplication sharedApplication] openURL:authURL];
    }
    else
    {
        self.authorizeHendler (nil, [JFFFoursquareAuthURLError new]);
    }
}

+ (BOOL)handleAuthOpenURL:(NSURL *)url
{
    return [[self shared] handleAuthOpenURL:url];
}

- (BOOL)handleAuthOpenURL:(NSURL *)url
{
    if ([url.absoluteString hasPrefix:[[self class] redirectURI]]) {
        NSString *accessToken = [[self class] accessTokenWithURL:url];
        if (accessToken ) {
            [[self class] saveAccessToken:accessToken];
            if (self.authorizeHendler) {
                self.authorizeHendler(accessToken, nil);
            }
            return YES;
        }
    }
    
    return NO;
}

+ (NSString *)accessTokenWithURL:(NSURL *)url
{
    //fq111://authorize#access_token=0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ
    NSString *path = url.absoluteString;
    NSRange rangeOfAccessTokenPrefix = [path rangeOfString:@"access_token"];
    NSInteger startIndex = NSMaxRange(rangeOfAccessTokenPrefix) + 1;
    
    if ([path length] <= startIndex ) {
        return nil;
    }
    
    return [path substringFromIndex:startIndex];

}

+ (NSString *)authURLString
{
    return [NSString stringWithFormat:FOURSQUARE_AUTH_URL_FORMAT, FOURSQUARE_CLIENT_ID, [self redirectURI]];
}

@end
