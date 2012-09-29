#import "NSError+Alert.h"

#import "JFFAlertView.h"

@implementation NSError (Alert)

- (void)showAlertWithTitle:(NSString *)title
{
    [self writeErrorToNSLog];
    [JFFAlertView showAlertWithTitle:title description:[self localizedDescription]];
}

- (void)showErrorAlert
{
    [self writeErrorToNSLog];
    [JFFAlertView showErrorWithDescription:[self localizedDescription]];
}

- (void)writeErrorToNSLog
{
    NSLog(@"NSError : %@, domain : %@ code : %d", [self localizedDescription], [self domain], [self code]);
}

- (void)showExclusiveErrorAlert
{
    [self writeErrorToNSLog];
    
    [JFFAlertView showExclusiveErrorWithDescription:[self localizedDescription]];
}

@end
