#import <GHUnitIOS/GHUnit.h>
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>
#import <JFFUI/JFFUI.h>

@interface JAlertTest : GHAsyncTestCase
@end
 
@implementation JAlertTest

-(void)testSingleButtonAlert
{
    __block __weak JFFAlertView* weakAlert_ = nil;
    __block BOOL alertVisible_ = NO;
    
    {
        TestAsyncRequestBlock showAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                                         message: @"Press OK"
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil ];
            
            weakAlert_ = alert_;
            [ alert_ show ];
            
            alertVisible_ = weakAlert_.isOnScreen;
            
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: showAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNotNil( weakAlert_, @"Alert view must exist until dismissed" );
        GHAssertTrue( alertVisible_, @"Alert view must be visible until dismissed" );
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];
        
        
        
        [ NSThread sleepForTimeInterval: 2.f ]; //Make sure dismiss has worked out
        dispatch_sync( dispatch_get_main_queue(), ^
        {
            alertVisible_ = weakAlert_.isOnScreen;
        } );
        
        GHAssertFalse( alertVisible_, @"Alert must have been dismissed" );
        GHAssertNil( weakAlert_, @"weak reference should have been collected" );
    }
}

-(void)testAlertsQueue
{
    __block __weak JFFAlertView* weakFirstAlert_  = nil;
    __block __weak JFFAlertView* weakSecondAlert_ = nil;
    __block BOOL alertVisible_ = NO;
    
    
    {
        TestAsyncRequestBlock showAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                                         message: @"Press OK"
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil ];
            
            weakFirstAlert_ = alert_;
            [ weakFirstAlert_ show ];
            
            
            alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                           message: @"Press YES"
                                 cancelButtonTitle: @"YES"
                                 otherButtonTitles: nil ];
            weakSecondAlert_ = alert_;
            [ weakSecondAlert_ show ];
            
            
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: showAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNotNil( weakFirstAlert_, @"First alert view must exist until dismissed"   );
        GHAssertNotNil( weakSecondAlert_, @"Second alert view must exist until dismissed" );
        
        
        
        dispatch_sync( dispatch_get_main_queue(), ^
        {
          alertVisible_ = weakFirstAlert_.isOnScreen;
        } );
        GHAssertTrue( alertVisible_, @"First alert view must be visible until dismissed" );
        
        dispatch_sync( dispatch_get_main_queue(), ^
        {
          alertVisible_ = weakSecondAlert_.isOnScreen;
        } );
        GHAssertFalse( alertVisible_, @"Second alert view must NOT be visible until first one gets dismissed" );
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakFirstAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];
        
        
        [ NSThread sleepForTimeInterval: 2.f ]; //Make sure dismiss has worked out
        dispatch_sync( dispatch_get_main_queue(), ^
        {
            alertVisible_ = weakFirstAlert_.isOnScreen;
        } );
        GHAssertFalse( alertVisible_, @"Alert must have been dismissed" );
        GHAssertNil( weakFirstAlert_, @"weak reference should have been collected" );
      

      
        GHAssertNotNil( weakSecondAlert_, @"Second alert reference should be alive" );
        dispatch_sync( dispatch_get_main_queue(), ^
        {
          alertVisible_ = weakSecondAlert_.isOnScreen;
        } );
        GHAssertTrue( alertVisible_, @"second alert must be visible" );
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakSecondAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];

        GHAssertNil( weakSecondAlert_, @"weak reference should have been collected" );
    }    
}
 
-(void)testExclusiveAlerts
{
    __block __weak JFFAlertView* weakFirstAlert_  = nil;
    __block __weak JFFAlertView* weakSecondAlert_ = nil;
    __block __weak JFFAlertView* weakThirdAlert_ = nil;
    __block BOOL alertVisible_ = NO;
    
    
    {
        TestAsyncRequestBlock showAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                                         message: @"Press OK"
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil ];
            
            weakFirstAlert_ = alert_;
            [ weakFirstAlert_ exclusiveShow ];
            
            
            alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                           message: @"Press YES"
                                 cancelButtonTitle: @"YES"
                                 otherButtonTitles: nil ];
            weakSecondAlert_ = alert_;
            [ weakSecondAlert_ exclusiveShow ];

            alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                           message: @"Third alert"
                                 cancelButtonTitle: @"Oh, YES"
                                 otherButtonTitles: nil ];
            weakThirdAlert_ = alert_;
            [ weakThirdAlert_ exclusiveShow ];
            
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: showAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNotNil( weakFirstAlert_, @"First alert view must exist until dismissed"   );
        GHAssertNil( weakSecondAlert_, @"Second alert must be suppressed. It won't ever be shown!" );
        GHAssertNil( weakThirdAlert_, @"Third alert must be suppressed. It won't ever be shown!" );   
        
        
        dispatch_sync( dispatch_get_main_queue(), ^
        {
            alertVisible_ = weakFirstAlert_.isOnScreen;
        } );
        GHAssertTrue( alertVisible_, @"First alert view must be visible until dismissed" );        
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakFirstAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNil( weakFirstAlert_, @"weak reference should have been collected" );
    }    
}

-(void)testAlertsQueueReverseOrder
{
    __block __weak JFFAlertView* weakFirstAlert_  = nil;
    __block __weak JFFAlertView* weakSecondAlert_ = nil;
    __block BOOL alertVisible_ = NO;
    
    
    {
        TestAsyncRequestBlock showAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                                         message: @"Press OK"
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil ];
            
            weakFirstAlert_ = alert_;
            [ weakFirstAlert_ show ];
            
            
            alert_ = [ JFFAlertView alertWithTitle: @"Title"
                                           message: @"Press YES"
                                 cancelButtonTitle: @"YES"
                                 otherButtonTitles: nil ];
            weakSecondAlert_ = alert_;
            [ weakSecondAlert_ show ];
            
            
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: showAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNotNil( weakFirstAlert_, @"First alert view must exist until dismissed"   );
        GHAssertNotNil( weakSecondAlert_, @"Second alert view must exist until dismissed" );
        
        
        
        dispatch_sync( dispatch_get_main_queue(), ^
                      {
                          alertVisible_ = weakFirstAlert_.isOnScreen;
                      } );
        GHAssertTrue( alertVisible_, @"First alert view must be visible until dismissed" );
        
        dispatch_sync( dispatch_get_main_queue(), ^
                      {
                          alertVisible_ = weakSecondAlert_.isOnScreen;
                      } );
        GHAssertFalse( alertVisible_, @"Second alert view must NOT be visible until first one gets dismissed" );
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakSecondAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];

        GHAssertNil( weakSecondAlert_, @"Second alert should have been deallocated" );
        GHAssertNotNil( weakFirstAlert_ , @"First alert must still live" );
        

        dispatch_sync( dispatch_get_main_queue(), ^
        {
          alertVisible_ = weakFirstAlert_.isOnScreen;
        } );
        GHAssertTrue( alertVisible_, @"First Alert must be still visible" );
    }
    
    
    {
        TestAsyncRequestBlock hideAlertBlock_ = ^void( JFFSimpleBlock finishTest_ )
        {
            [ weakFirstAlert_ forceDismiss ];
            finishTest_();
        };
        
        [ self performAsyncRequestOnMainThreadWithBlock: hideAlertBlock_
                                               selector: _cmd ];
        
        GHAssertNil( weakFirstAlert_, @"RIP First alert. Finally..." );
    }    
}

@end
