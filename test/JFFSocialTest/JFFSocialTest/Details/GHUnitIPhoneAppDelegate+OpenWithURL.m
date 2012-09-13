
#import <JFFSocial/Forsquare/ForsquareSession/JFFForsquareSessionStorage.h>

@interface GHUnitIPhoneAppDelegate (OpenWithURL)
@end

@implementation GHUnitIPhoneAppDelegate (OpenWithURL)

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return NO;
}

@end
