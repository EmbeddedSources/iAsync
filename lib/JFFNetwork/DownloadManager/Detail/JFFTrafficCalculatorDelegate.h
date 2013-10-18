#import <Foundation/Foundation.h>

@class JFFTrafficCalculator;

@protocol JFFTrafficCalculatorDelegate <NSObject>

- (void)trafficCalculator:(JFFTrafficCalculator *)trafficCalculator
   didChangeDownloadSpeed:(float)speed;

@end
