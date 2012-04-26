#import <Foundation/Foundation.h>

@class JFFScheduler;

@interface NSObject (Scheduler)

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" object from memory
-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_
               repeats:( BOOL )repeats_;

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" or "scheduler" object from memory
-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_ 
               repeats:( BOOL )repeats_
             scheduler:( JFFScheduler* )scheduler_;

@end
