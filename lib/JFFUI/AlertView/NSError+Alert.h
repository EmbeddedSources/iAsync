#import <Foundation/Foundation.h>

@interface NSError (Alert)

-(void)showAlertWithTitle:( NSString* )title_;

-(void)showErrorAlert;
-(void)showExclusiveErrorAlert;

-(void)writeErrorToNSLog;

@end
