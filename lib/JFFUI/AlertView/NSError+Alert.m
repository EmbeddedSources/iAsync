#import "NSError+Alert.h"

#import "JFFAlertView.h"

@implementation NSError (Alert)

- (void)showAlertWithTitle:(NSString *)title
{
    [self writeErrorWithJFFLogger];
    [JFFAlertView showAlertWithTitle:title description:[self localizedDescription]];
}

- (void)showErrorAlert
{
    [self writeErrorWithJFFLogger];
    [JFFAlertView showErrorWithDescription:[self localizedDescription]];
}

- (void)showExclusiveErrorAlert
{
    [self writeErrorWithJFFLogger];
    [JFFAlertView showExclusiveErrorWithDescription:[self localizedDescription]];
}

@end
