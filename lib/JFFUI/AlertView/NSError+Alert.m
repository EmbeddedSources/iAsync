#import "NSError+Alert.h"

#import "JFFAlertView.h"

#import <JFFAsyncOperations/Errors/JFFAsyncOpFinishedByCancellationError.h>
#import <JFFAsyncOperations/Errors/JFFAsyncOpFinishedByUnsubscriptionError.h>

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

@implementation JFFAsyncOpFinishedByCancellationError (Alert)

- (void)showAlertWithTitle:(NSString *)title
{
    [self writeErrorWithJFFLogger];
}

- (void)showErrorAlert
{
    [self writeErrorWithJFFLogger];
}

- (void)showExclusiveErrorAlert
{
    [self writeErrorWithJFFLogger];
}

@end

@implementation JFFAsyncOpFinishedByUnsubscriptionError (Alert)

- (void)showAlertWithTitle:(NSString *)title
{
    [self writeErrorWithJFFLogger];
}

- (void)showErrorAlert
{
    [self writeErrorWithJFFLogger];
}

- (void)showExclusiveErrorAlert
{
    [self writeErrorWithJFFLogger];
}

@end
