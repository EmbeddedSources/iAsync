#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <JFFUI/AlertView/JFFAlertView.h>

#import <Foundation/Foundation.h>

typedef JFFAlertView *(^JFFAlertViewBuilder)(void);

@interface JFFAlertView (Async)

+ (JFFAsyncOperation)showAlerLoaderWithBuilder:(JFFAlertViewBuilder)builder;

@end
