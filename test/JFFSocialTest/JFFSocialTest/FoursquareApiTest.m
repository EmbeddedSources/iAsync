
#import <JFFSocial/Forsquare/ForsquareSession/JFFForsquareSessionStorage.h>
/*

 fq111://authorize#access_token=0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ
*/

#define ACCESS_TOKEN @"0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ"

@interface FoursquareApiTest : GHAsyncTestCase
@end


@implementation FoursquareApiTest

- (void)testAuthURLHandling
{
    NSURL *frAuthGoodURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@#access_token=%@", [JFFForsquareSessionStorage redirectURI], ACCESS_TOKEN]];
    NSURL *frAuthBadURL1 = [NSURL URLWithString:@"http://#access_token=0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ"];
    NSURL *frAuthBadURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@#access_token=", [JFFForsquareSessionStorage redirectURI]]];
    NSURL *frAuthBadURL3 = [NSURL URLWithString:[NSString stringWithFormat:@"%@#=0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ", [JFFForsquareSessionStorage redirectURI]]];
    
    GHAssertTrue([JFFForsquareSessionStorage handleAuthOpenURL:frAuthGoodURL],  @"valid auth URL didn`t handle");
    GHAssertFalse([JFFForsquareSessionStorage handleAuthOpenURL:frAuthBadURL1], @"did handle invalid URL %@", frAuthBadURL1);
    GHAssertFalse([JFFForsquareSessionStorage handleAuthOpenURL:frAuthBadURL2], @"did handle invalid URL %@", frAuthBadURL2);
    GHAssertFalse([JFFForsquareSessionStorage handleAuthOpenURL:frAuthBadURL3], @"did handle invalid URL %@", frAuthBadURL3);
    
    GHAssertEqualStrings([JFFForsquareSessionStorage accessToken], ACCESS_TOKEN, @"invalid stored access token");
}

- (void)testAuth
{
    [self prepare];
    
    SEL selector = _cmd;
    [[JFFForsquareSessionStorage shared] openSessionWithHandler:^(NSString *result, NSError *error) {
        if ([result length] > 0) {
            [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
        }
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1000.0];
}

@end
