
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

@interface JFFSocialInstagram (InstagramApiTest)

+ (JFFAsyncOperation)authedUserLoaderWithCredentials:(JFFInstagramCredentials *)redentials;

@end

/*
 Test account:

 volodg
 H4d3yl8x
 */

static NSString *const clientId     = @"ed29def3a9ad49ccb8211de63493a682";
static NSString *const clientSecret = @"876c42a9dcb7474093be81d46d5a5a8e";
static NSString *const redirectURI  = @"ed29def3a9ad49ccb8211de63493a682://test";

static NSString *const accessToken = @"220778258.ed29def.b8a18d6838c04b4790b39024fde8db51";

@interface InstagramApiTest : GHAsyncTestCase
@end

@implementation InstagramApiTest

//basic - to read any and all data related to a user (e.g. following/followed-by lists, photos, etc.) (granted by default)
//comments - to create or delete comments on a user’s behalf
//relationships - to follow and unfollow users on a user’s behalf
//likes - to like and unlike items on a user’s behalf

//comments
-(void)RtestInstagramAuthedUser
{
    __block JFFInstagramAuthedAccount *account;
    
    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFInstagramCredentials *credentials = [JFFInstagramCredentials new];
        credentials.clientId     = clientId;
        credentials.clientSecret = clientSecret;
        credentials.redirectURI  = redirectURI;
        
        JFFAsyncOperation loader = [JFFSocialInstagram authedUserLoaderWithCredentials:credentials];
        
        loader(nil,nil,^(id result,NSError *error) {
            account = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(account, @"ok");

    GHAssertEqualObjects( @"volodg", account.name, @"instagram result.name mismatch");
    GHAssertEqualObjects( @"220778258", account.instagramAccountId, @"instagram id mismatch");
    GHAssertEqualObjects( @"http://images.instagram.com/profiles/profile_220778258_75sq_1347279105.jpg"
                         , [account.avatarURL description], @"instagram url mismatch");

}

-(void)testInstagramFollowersLoader
{
    __block NSArray *followers;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFInstagramCredentials *credentials = [JFFInstagramCredentials new];
        credentials.clientId     = clientId;
        credentials.clientSecret = clientSecret;
        credentials.redirectURI  = redirectURI;

        JFFAsyncOperation loader = [JFFSocialInstagram followedByLoaderWithCredentials:credentials];

        loader(nil,nil,^(id result,NSError *error)
        {
            followers = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(followers, @"ok");

    GHAssertTrue([followers count]>=2, @"ok");

    JFFInstagramAccount *vlg1Account = [followers firstMatch:^BOOL(JFFInstagramAccount *account)
    {
        return [account.name isEqualToString:@"vlg1"];
    }];

    GHAssertEqualObjects( @"vlg1", vlg1Account.name, @"instagram result.name mismatch");
    GHAssertEqualObjects( @"221327437", vlg1Account.instagramAccountId, @"instagram id mismatch");
    GHAssertEqualObjects( @"http://images.instagram.com/profiles/profile_221327437_75sq_1347390023.jpg"
                         , [vlg1Account.avatarURL description], @"instagram url mismatch");

    JFFInstagramAccount *vlg2Account = [followers firstMatch:^BOOL(JFFInstagramAccount *account)
    {
        return [account.name isEqualToString:@"vlg2"];
    }];

    GHAssertEqualObjects( @"vlg2", vlg2Account.name, @"instagram result.name mismatch");
    GHAssertEqualObjects( @"221328639", vlg2Account.instagramAccountId, @"instagram id mismatch");
    GHAssertEqualObjects( @"http://images.instagram.com/profiles/profile_221328639_75sq_1347390138.jpg"
                         , [vlg2Account.avatarURL description], @"instagram url mismatch");
}

-(void)testInstagramAuthedUserByAccessToken
{
    __block JFFInstagramAuthedAccount *account;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialInstagram userLoaderForForUserId:@"self"
                                                                  accessToken:accessToken];

        loader(nil,nil,^(id result,NSError *error)
        {
            account = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    NSLog(@"account: %@", account);

    GHAssertNotNil(account, @"ok");

    GHAssertEqualObjects( @"volodg", account.name, @"instagram result.name mismatch");
    GHAssertEqualObjects( @"220778258", account.instagramAccountId, @"instagram id mismatch");
    GHAssertEqualObjects( @"http://images.instagram.com/profiles/profile_220778258_75sq_1347279105.jpg"
                         , [account.avatarURL description], @"instagram url mismatch");
}

-(void)testLoadOwnMediaItems
{
    __block NSArray *mediaItems;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialInstagram recentMediaItemsLoaderForUserId:nil
                                                                           accessToken:accessToken];

        loader(nil,nil,^(id result,NSError *error)
        {
            mediaItems = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(mediaItems, @"ok");
    GHAssertTrue([mediaItems count]>0, @"ok");

    JFFInstagramMediaItem *mediaItem = mediaItems[0];

    GHAssertEqualObjects( @"277393673043504646_220778258", mediaItem.mediaItemId, @"instagram id mismatch");

    {
        NSString *url = @"http://distilleryimage10.s3.amazonaws.com/38ec2cd4fb5511e19ca422000a1d0119_7.jpg";
        GHAssertEqualObjects(url, [mediaItem.bigImageUrl description], @"instagram id mismatch");
    }
    {
        NSString *url = @"http://distilleryimage10.s3.amazonaws.com/38ec2cd4fb5511e19ca422000a1d0119_5.jpg";
        GHAssertEqualObjects(url, [mediaItem.thumbnailImageUrl description], @"instagram id mismatch");
    }
}

-(void)testLoadVlg1MediaItems
{
    __block NSArray *mediaItems;

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialInstagram recentMediaItemsLoaderForUserId:@"221327437"
                                                                           accessToken:accessToken];

        loader(nil,nil,^(id result,NSError *error)
        {
            mediaItems = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(mediaItems, @"ok");
    GHAssertTrue([mediaItems count]==2, @"ok");

    JFFInstagramMediaItem *mediaItem = mediaItems[0];

    GHAssertEqualObjects( @"284572159972875249_221327437", mediaItem.mediaItemId, @"instagram id mismatch");
}

-(void)testCommentVlg1MediaItem
{
    __block JFFInstagramComment *comment;

    NSString *commentText = @"please visit site: www.wishdates.com, (this is test message)";

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialInstagram commentMediaItemLoaderWithId:@"278621428023433649_221327437"
                                                                            comment:commentText
                                                                        accessToken:accessToken];

        loader(nil,nil,^(id result,NSError *error)
        {
            comment = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(comment, @"ok");

    GHAssertEqualObjects(commentText, comment.text, @"instagram id mismatch");
}

-(void)testSendMessageToFollowers
{
    __block NSArray *comments;
    
    NSString *commentText = @"please visit site: www.wishdates.com, (this is test message)";

    TestAsyncRequestBlock block = ^(JFFSimpleBlock finishBLock)
    {
        JFFAsyncOperation loader = [JFFSocialInstagram notifyUsersFollowersWithId:@"self"
                                                                          message:commentText
                                                                      accessToken:accessToken];
        
        loader(nil,nil,^(id result,NSError *error)
        {
            comments = result;
            finishBLock();
        });
    };

    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd];

    GHAssertNotNil(comments, @"ok");

    for (JFFInstagramComment *comment in comments)
    {
        GHAssertEqualObjects(commentText, comment.text, @"comment text mismatch");
    }
}

@end
