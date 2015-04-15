
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

@interface JFFActionSheetTest : GHAsyncTestCase
@end

@implementation JFFActionSheetTest

- (void)testEmptyActionSheetAndHide
{
    __block __weak JFFActionSheet *weakActionSheet;

    void (^showActionSheetBlock_)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishTest) {
        
        JFFActionSheet *actionSheet = [JFFActionSheet actionSheetWithTitle:@"Test Empty"
                                                          cancelButtonTitle:nil
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];
        
        weakActionSheet = actionSheet;
        
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
        finishTest();
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:showActionSheetBlock_
                                          selector:_cmd];
    
    GHAssertNotNil(weakActionSheet, @"OK");
    
    void (^hideActionSheetBlock_)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishTest)
    {
        [weakActionSheet dismissWithClickedButtonIndex:0
                                              animated:NO];
        
        finishTest();
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:hideActionSheetBlock_
                                          selector:_cmd];
    
    GHAssertNil(weakActionSheet, @"OK");
}

- (void)testActionWithTitle
{
    __block __weak JFFActionSheet *weakActionSheet;
    
    void (^showActionSheetBlock)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishTest)
    {
        JFFActionSheet *actionSheet = [JFFActionSheet actionSheetWithTitle:@"Test With Cancel"
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
        
        weakActionSheet = actionSheet;
        
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
        finishTest();
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:showActionSheetBlock
                                          selector:_cmd];
    
    GHAssertNotNil(weakActionSheet, @"OK");
    
    void (^hideActionSheetBlock_)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishTest)
    {
        [weakActionSheet dismissWithClickedButtonIndex:0
                                              animated:NO];
        
        finishTest();
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:hideActionSheetBlock_
                                          selector:_cmd];
    
    GHAssertNil(weakActionSheet, @"OK");
}

@end
