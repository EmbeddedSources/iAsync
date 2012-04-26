#import <Foundation/Foundation.h>

@protocol JFFTrafficCalculatorDelegate;

typedef void (^RICancelCalculateSpeed) ( void );

@interface JFFTrafficCalculator : NSObject

-(id)initWithDelegate:( id< JFFTrafficCalculatorDelegate > )delegate_;

-(void)startLoading;

-(void)stop;

-(void)bytesReceived:( NSUInteger )bytes_count_;

@end
