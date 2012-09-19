#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

#import <JFFSocial/Twitter/AsyncAdapters/JFFAsyncTwitterCreateAccount.h>
#import <JFFSocial/Twitter/Parsers/NSArray+TweetsJSONParser.h>

/*
 hc_test
 @hc_test3
 human.cloud.test@gmail.com
 humancloud
 
 hc_test1
 @hc_test110
 human.cloud.test1@gmail.com
 humancloud
 
 hc_test2
 @hc_test210
 human.cloud.test2@gmail.com
 humancloud
 */

@interface TwitterApiTest : GHAsyncTestCase
@end

@implementation TwitterApiTest

#if !(TARGET_IPHONE_SIMULATOR)
-(void)testTwitterNearbyCoordinates
{
    __block BOOL finishedAsNotGrantedAccess = NO;
    
    __block NSArray *users;
    
    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialTwitter usersNearbyCoordinatesLantitude:40.3
                                                                           longitude:71.51];
        
        loader(nil,nil,^(id result,NSError *error)
        {
            if ([error isMemberOfClass:[JFFTwitterAccountAccessNotGrantedError class]])
            {
                finishBLock();
                return;
            }
            users = result;
            finishBLock();
        });
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                           selector:_cmd];
    
    if (finishedAsNotGrantedAccess)
    {
        //skip asserts
        return;
    }
    
    GHAssertNotNil(users, @"ok");
    GHAssertEquals( (NSUInteger)100, [users count], @"tweets count mismatch");
    
    JFFTwitterAccount* firstAccount = users[0];
    
    GHAssertNotNil( firstAccount.twitterAccountId, @"tweet id mismatch");
    GHAssertNotNil( firstAccount.name, @"tweet name mismatch");
    GHAssertNotNil( firstAccount.avatarURL, @"tweet avatarURL mismatch");
}

-(void)testRetriveFollowers
{
    __block BOOL finishedAsNotGrantedAccess = NO;

    __block NSArray *users;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialTwitter followersLoader];

        loader(nil,nil,^(id result,NSError *error)
        {
            if ( [error isMemberOfClass:[JFFTwitterAccountAccessNotGrantedError class]] )
            {
                finishBLock();
                return;
            }
            users = result;
            finishBLock();
       });
    };

    [ self performAsyncRequestOnMainThreadWithBlock:block
                                           selector:_cmd ];

    if (finishedAsNotGrantedAccess)
    {
        //skip asserts
        return;
    }

    GHAssertNotNil(users, @"ok");

    GHAssertEquals( (NSUInteger)2, [users count], @"followers count mismatch");

    users = [users sortedArrayUsingComparator:^NSComparisonResult(JFFTwitterAccount *obj1, JFFTwitterAccount *obj2)
    {
        return [obj1.twitterAccountId compare:obj2.twitterAccountId];
    }];

    NSUInteger twitterAccountIndex = 0;
    {
        JFFTwitterAccount* twitterAccount = users[twitterAccountIndex];

        GHAssertEqualStrings( @"806425640", twitterAccount.twitterAccountId, @"tweet id mismatch");
        GHAssertEqualStrings( @"hc_test1", twitterAccount.name, @"tweet name mismatch");
        GHAssertNotNil( twitterAccount.avatarURL, @"tweet avatarURL mismatch");
    }

    twitterAccountIndex = 1;
    {
        JFFTwitterAccount* twitterAccount = users[twitterAccountIndex];

        GHAssertEqualStrings( @"806434819", twitterAccount.twitterAccountId, @"tweet id mismatch");
        GHAssertEqualStrings( @"hc_test2", twitterAccount.name, @"tweet name mismatch");
        GHAssertNotNil( twitterAccount.avatarURL, @"tweet avatarURL mismatch");
    }
}

-(void)testSendDirectMessage
{
    __block BOOL finishedAsNotGrantedAccess = NO;

    __block JFFDirectTweetMessage *message;

    NSString *messageToSend = [NSString createUuid];

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        NSLog(@"sending tweet message: %@", message);
        JFFAsyncOperation loader = [JFFSocialTwitter sendDirectMessage:messageToSend
                                                      toFollowerWithId:@"806425640"];

        loader(nil,nil,^(id result,NSError *error)
        {
            if ([error isMemberOfClass:[JFFTwitterAccountAccessNotGrantedError class]])
            {
                finishBLock();
                return;
            }
            message = result;
            finishBLock();
        });
    };

    [ self performAsyncRequestOnMainThreadWithBlock:block
                                           selector:_cmd ];

    if (finishedAsNotGrantedAccess)
    {
        //skip asserts
        return;
    }

    GHAssertNotNil(message, @"ok");
    GHAssertEqualStrings( messageToSend, message.text, @"tweet name mismatch");
}
#endif

- (void)testExample
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"twitter_geolocation"
                                                         ofType:@"json"];

    NSData *jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];

    NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];

    NSArray *tweets = [NSArray newTweetsWithJSONObject:jsonObject error:NULL];

    GHAssertNotNil(tweets, @"ok");
    GHAssertEquals( (NSUInteger)100, [tweets count], @"tweets count mismatch");

    JFFTweet* firstTweet = tweets[0];

    GHAssertEqualStrings( @"244037846334337024", firstTweet.tweetId, @"tweet id mismatch");
    static NSString *expectedText = @"RT @imrifa: please rubah sikap lo!ex-verrt sayang sama lo!ex-verrt pengen lo yang dulu,bukan yang sekarang! :'/";
    GHAssertEqualStrings( expectedText, firstTweet.text, @"tweet id mismatch");

    JFFTwitterAccount *firstAccount = firstTweet.user;
    GHAssertEqualStrings( @"488435294", firstAccount.twitterAccountId, @"tweet id mismatch");
    GHAssertEqualStrings( @"Ex-verrt!", firstAccount.name, @"tweet name mismatch");

    NSURL* expectedUrl = [[NSURL alloc]initWithString:@"http://a0.twimg.com/profile_images/2463179580/9lpd4xidh3rojaqa773q_normal.jpeg"];
    GHAssertEqualObjects( expectedUrl, firstAccount.avatarURL, @"tweet avatarURL mismatch");
}

-(void)RtestCreateTwitterAccount
{
    __block BOOL finishedAsNotGrantedAccess = NO;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = jffCreateTwitterAccountLoader();

        loader(nil,nil,^(id result,NSError *error)
        {
//            if ( [error isMemberOfClass:[JFFTwitterAccountAccessNotGrantedError class]] )
//            {
//                finishBLock();
//                return;
//            }
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    if (finishedAsNotGrantedAccess)
    {
        //skip asserts
        return;
    }

    GHAssertFalse(NO, @"Nil String[%@] should have no symbols");
}

@end
