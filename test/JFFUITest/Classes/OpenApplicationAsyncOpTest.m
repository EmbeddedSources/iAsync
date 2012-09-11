
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>
#import <JFFUtils/JFFUtils.h>

//TODO workaround to hook delegate method
//TODO fix this workaround
@implementation GHUnitIPhoneAppDelegate (OpenApplicationAsyncOpTest)

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return NO;
}

@end

@interface OpenApplicationAsyncOpTest : GHAsyncTestCase
@end

@implementation OpenApplicationAsyncOpTest

-(void)testActionWithTitle
{
    __block NSURL *resultURL;

    void (^test)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishTest)
    {
        UIApplication *application = [UIApplication sharedApplication];

        NSURL *url = [@"https://instagram.com/oauth/authorize/?client_id=ce275877963c451ca44e2c04b69f2029&redirect_uri=ce275877963c451ca44e2c04b69f2029%3a%2f%2ftest&response_type=code" toURL];
        JFFAsyncOperation loader = [application asyncOperationWithApplicationURL:url];

        loader(nil, nil, ^(id result, NSError *error)
        {
            resultURL = result;
            finishTest();
        });
    };

    [ self performAsyncRequestOnMainThreadWithBlock: test
                                           selector: _cmd ];

    GHAssertEqualObjects(@"ce275877963c451ca44e2c04b69f2029",
                         [resultURL scheme],
                         @"result url mismatch");
}

@end
