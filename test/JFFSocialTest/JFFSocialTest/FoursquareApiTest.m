
#import <JFFSocial/Forsquare/ForsquareSession/JFFForsquareSessionStorage.h>
#import <JFFSocial/Forsquare/JFFSocialForsquare.h>

#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

#import <JFFSocial/Forsquare/Model/FoursquareUserModel.h>

/*

 fq111://authorize#access_token=0WA2I2N1RDHMOVKZESV15ELMALCGC1T2M23UPJMYEMM2WNMZ
 Logined via Facebook - test.dev.and@gmail.com, pwd: 123qweasdzxc456
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

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialForsquare authLoader];
        
        loader(nil,nil,^(id result,NSError *error)
               {
                   NSLog(@"Access token: %@", result);
                   finishBLock();
               });
    };
    
    [ self performAsyncRequestOnMainThreadWithBlock:block
                                           selector:_cmd ];
}

- (void)testFriendsLoader
{
    [self prepare];
    
    SEL selector = _cmd;
    [JFFSocialForsquare myFriendsLoader] (nil, nil, ^(id result, NSError *error)
                                          {
                                              if (!error && [result isKindOfClass:[NSArray class]] && [result count] > 0)
                                              {
                                                  for (FoursquareUserModel *model  in result) {
                                                      NSLog(@"Model: %@", model.contacts);
                                                  }
                                                  
                                                  [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
                                              }
                                              else
                                              {
                                                  [self notify:kGHUnitWaitStatusFailure forSelector:selector];
                                              }
                                              
                                          });
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:100.0];
}

- (void)testCheckinsLoader
{
    [self prepare];
    
    SEL selector = _cmd;
    [JFFSocialForsquare checkinsLoaderWithUserId:nil limit:1] (nil, nil, ^(id result, NSError *error)
                                          {
                                              if (!error && [result isKindOfClass:[NSArray class]] && [result count] > 0)
                                              {
                                                  [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
                                              }
                                              else
                                              {
                                                  [self notify:kGHUnitWaitStatusFailure forSelector:selector];
                                              }
                                              
                                          });
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:100.0];
}

- (void)testAddPostToCheckin
{
    [self prepare];
    
    SEL selector = _cmd;
    [JFFSocialForsquare addPostToCheckin:@"5051a006e4b08eccb1257587"
                                withText:@"Hi!"
                                     url:@"http://wishdates.com"
                               contentID:nil]
    (nil, nil, ^(id result, NSError *error)
     {
         if (!error)
         {
             [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
         }
         else
         {
             [self notify:kGHUnitWaitStatusFailure forSelector:selector];
         }
         
     });
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:100.0];
}

@end
