#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <GHUnitIOS/GHUnit.h>
#import <Foundation/Foundation.h>

@interface GHAsyncTestCase (MainThreadTests)

-(void)performAsyncRequestOnMainThreadWithBlock:( void (^)(JFFSimpleBlock) )block_
                                       selector:( SEL )selector_;


@end
