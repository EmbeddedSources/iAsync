#import "NSError+Alert.h"

#import "JFFAlertView.h"

@implementation NSError (Alert)

-(void)showAlertWithTitle:( NSString* )title_
{
    [ self writeErrorToNSLog ];
    [ JFFAlertView showAlertWithTitle: title_ description: [ self localizedDescription ] ];
}

-(void)showErrorAlert
{
    [ self writeErrorToNSLog ];
    [ JFFAlertView showErrorWithDescription: [ self localizedDescription ] ];
}

-(void)writeErrorToNSLog
{
    NSLog( @"NSError : %@, domain : %@ code : %d", [ self localizedDescription ], [ self domain ], [ self code ] );
}

-(void)showExclusiveErrorAlert
{
    [ self writeErrorToNSLog ];

    [ JFFAlertView showExclusiveErrorWithDescription: [ self localizedDescription ] ];
}

@end
