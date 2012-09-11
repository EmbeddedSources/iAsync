
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>
#import <JFFUtils/JFFUtils.h>

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
            finishTest();
        });
    };

    [ self performAsyncRequestOnMainThreadWithBlock: test
                                           selector: _cmd ];

    NSLog(@"resultURL: %@", resultURL);
    GHAssertNotNil( resultURL, @"OK" );
}

@end
