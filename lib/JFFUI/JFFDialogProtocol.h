#import <Foundation/Foundation.h>

typedef void (^JFFCompleteDialogCallbackBlock)(id result, NSError *error, BOOL isCanceled);

@protocol JFFDialogProtocol <NSObject>

@property (copy, nonatomic) JFFCompleteDialogCallbackBlock onCompleteDialogBlock;

@required
- (void)completeDialogWithResult:(id)result error:(NSError *)error isCanceled:(BOOL)isCancaled;
- (void)completeDialogWithError:(NSError *)error;
- (void)completeDialogWithResult:(id)result;
- (void)cancelDialog;

@end
