#import "NSObject+Scheduler.h"

#import "JFFScheduler.h"

#import <JFFUtils/NSString/NSString+Search.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>

#include <objc/message.h>

@implementation NSObject (Scheduler)

//JTODO test !!!
-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )timeInterval_
              userInfo:( id )userInfo_
               repeats:( BOOL )repeats_
             scheduler:( JFFScheduler* )scheduler_
{
    NSParameterAssert( scheduler_ );

    //use signature's number params
    NSString* selectorString_ = NSStringFromSelector( selector_ );
    NSUInteger numOfArgs_ = [ selectorString_ numberOfCharacterFromString: @":" ];
    NSAssert1( numOfArgs_ == 0 || numOfArgs_ == 1
              , @"selector \"%@\" should has 0 or 1 parameters"
              , selectorString_ );

    __unsafe_unretained id self_ = self;

    JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
    {
        if ( !repeats_ )
        {
            [ self_ removeOnDeallocBlock: cancel_ ];
            cancel_();
        }

        numOfArgs_ == 1
            ? objc_msgSend( self_, selector_, userInfo_ )
            : objc_msgSend( self_, selector_ );
    };

    JFFCancelScheduledBlock cancel_ = [ scheduler_ addBlock: block_
                                                   duration: timeInterval_ ];
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
                 scheduler: [ JFFScheduler sharedByThreadScheduler ] ];
}

@end
