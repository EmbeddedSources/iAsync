#import <Foundation/Foundation.h>

@protocol JFFTrafficCalculatorDelegate;

typedef void (^RICancelCalculateSpeed) ( void );

@interface JFFTrafficCalculator : NSObject
{
@private
   RICancelCalculateSpeed _cancel_calculate_speed_block;
   NSMutableArray* _downloading_speed_info;

   id< JFFTrafficCalculatorDelegate > _delegate;
}

-(id)initWithDelegate:( id< JFFTrafficCalculatorDelegate > )delegate_;

-(void)startLoading;

-(void)stop;

-(void)bytesReceived:( NSUInteger )bytes_count_;

@end
