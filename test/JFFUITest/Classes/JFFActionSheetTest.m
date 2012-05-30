
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

@interface JFFActionSheetTest : GHAsyncTestCase
@end

@implementation JFFActionSheetTest

-(void)testEmptyActionSheetAndHide
{
    __block __weak JFFActionSheet* weakActionSheet_;

    void (^showActionSheetBlock_)(JFFSimpleBlock) = ^void( JFFSimpleBlock finishTest_ )
    {
        JFFActionSheet* actionSheet_ = [ JFFActionSheet actionSheetWithTitle: @"Test Empty"
                                                           cancelButtonTitle: nil
                                                      destructiveButtonTitle: nil
                                                           otherButtonTitles: nil ];

        weakActionSheet_ = actionSheet_;

        [ actionSheet_ showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];

        finishTest_();
    };

    [ self performAsyncRequestOnMainThreadWithBlock: showActionSheetBlock_
                                           selector: _cmd ];

    GHAssertNotNil( weakActionSheet_, @"OK" );

    void (^hideActionSheetBlock_)(JFFSimpleBlock) = ^void( JFFSimpleBlock finishTest_ )
    {
        [ weakActionSheet_ dismissWithClickedButtonIndex: 0
                                                animated: NO ];

        finishTest_();
    };

    [ self performAsyncRequestOnMainThreadWithBlock: hideActionSheetBlock_
                                           selector: _cmd ];

    GHAssertNil( weakActionSheet_, @"OK" );
}

-(void)testActionWithTitle
{
    __block __weak JFFActionSheet* weakActionSheet_;

    void (^showActionSheetBlock_)(JFFSimpleBlock) = ^void( JFFSimpleBlock finishTest_ )
    {
        JFFActionSheet* actionSheet_ = [ JFFActionSheet actionSheetWithTitle: @"Test With Cancel"
                                                           cancelButtonTitle: @"Cancel"
                                                      destructiveButtonTitle: nil
                                                           otherButtonTitles: nil ];

        weakActionSheet_ = actionSheet_;

        [ actionSheet_ showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];

        finishTest_();
    };

    [ self performAsyncRequestOnMainThreadWithBlock: showActionSheetBlock_
                                           selector: _cmd ];

    GHAssertNotNil( weakActionSheet_, @"OK" );

    void (^hideActionSheetBlock_)(JFFSimpleBlock) = ^void( JFFSimpleBlock finishTest_ )
    {
        [ weakActionSheet_ dismissWithClickedButtonIndex: 0
                                                animated: NO ];

        finishTest_();
    };

    [ self performAsyncRequestOnMainThreadWithBlock: hideActionSheetBlock_
                                           selector: _cmd ];

    GHAssertNil( weakActionSheet_, @"OK" );
}

@end
