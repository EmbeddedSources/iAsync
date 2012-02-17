#import "NSObject+Scheduler.h"

#import "JFFScheduler.h"

#import <JFFUtils/NSString/NSString+Search.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>

#include <objc/message.h>

@implementation NSObject (Scheduler)

-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_ 
               repeats:( BOOL )repeats_
             scheduler:( JFFScheduler* )scheduler_
{
    NSParameterAssert( scheduler_ );

    NSString* selector_string_ = NSStringFromSelector( selector_ );
    NSUInteger num_of_args_ = [ selector_string_ numberOfCharacterFromString: @":" ];
    NSAssert1( num_of_args_ == 0 || num_of_args_ == 1, @"selector \"%@\" should has 0 or 1 parameters", selector_string_ );

    __block id self_ = self;

    JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
    {
        if ( !repeats_ )
        {
            [ self_ removeOnDeallocBlock: cancel_ ];
            cancel_();
        }

        num_of_args_ == 1
            ? objc_msgSend( self_, selector_, user_info_ )
            : objc_msgSend( self_, selector_ );
    };

    JFFCancelScheduledBlock cancel_ = [ scheduler_ addBlock: block_ duration: time_interval_ ];
    [ self addOnDeallocBlock: cancel_ ];
}

-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_ 
               repeats:( BOOL )repeats_
{
    [ self performSelector: selector_
              timeInterval: time_interval_
                  userInfo: user_info_ 
                   repeats: repeats_
                 scheduler: [ JFFScheduler sharedScheduler ] ];
}

@end
