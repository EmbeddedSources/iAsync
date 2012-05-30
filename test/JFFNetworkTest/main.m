#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnit.h>

void exceptionHandler(NSException *exception);

// Default exception handler
void exceptionHandler(NSException *exception)
{ 
    NSLog(@"%@\n%@", [exception reason], GHUStackTraceFromException(exception));
}

int main(int argc, char *argv[]) 
{
    /*!
     For debugging:
     Go into the "Get Info" contextual menu of your (test) executable (inside the "Executables" group in the left panel of XCode). 
     Then go in the "Arguments" tab. You can add the following environment variables:

     Default:   Set to:
     NSDebugEnabled                        NO       "YES"
     NSZombieEnabled                       NO       "YES"
     NSDeallocateZombies                   NO       "YES"
     NSHangOnUncaughtException             NO       "YES"

     NSEnableAutoreleasePool              YES       "NO"
     NSAutoreleaseFreedObjectCheckEnabled  NO       "YES"
     NSAutoreleaseHighWaterMark             0       non-negative integer
     NSAutoreleaseHighWaterResolution       0       non-negative integer

     For info on these varaiables see NSDebug.h; http://theshadow.uw.hu/iPhoneSDKdoc/Foundation.framework/NSDebug.h.html

     For malloc debugging see: http://developer.apple.com/mac/library/documentation/Performance/Conceptual/ManagingMemory/Articles/MallocDebug.html
     */

    setenv( "GHUNIT_AUTORUN" , "YES", 1 );
    setenv( "WRITE_JUNIT_XML", "YES", 1 );
    setenv( "GHUNIT_AUTOEXIT" , "YES", 1 );
    NSSetUncaughtExceptionHandler(&exceptionHandler);

    @autoreleasepool
    {
        // Register any special test case classes
        //[[GHTesting sharedInstance] registerClassName:@"GHSpecialTestCase"];  
   
        int retVal = 0;
        // If GHUNIT_CLI is set we are using the command line interface and run the tests
        // Otherwise load the GUI app
        if (getenv("GHUNIT_CLI"))
        {
            retVal = [GHTestRunner run];
        } 
        else 
        {
            retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIPhoneAppDelegate");
        }

        return retVal;
    }
}
