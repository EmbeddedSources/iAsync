#import <Foundation/Foundation.h>

@protocol JFFTrafficCalculatorDelegate;

typedef void (^RICancelCalculateSpeed) (void);

@interface JFFTrafficCalculator : NSObject

- (instancetype)initWithDelegate:(id<JFFTrafficCalculatorDelegate>)delegate;

- (void)startLoading;

- (void)stop;

- (void)bytesReceived:(NSUInteger)bytesCount;

@end
