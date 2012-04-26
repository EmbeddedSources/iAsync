#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <GHUnitIOS/GHUnit.h>
#import <Foundation/Foundation.h>

typedef void (^TestAsyncRequestBlock)(JFFSimpleBlock);

@interface GHAsyncTestCase (MainThreadTests)

-(void)performAsyncRequestOnMainThreadWithBlock:( void (^)(JFFSimpleBlock) )block_
                                       selector:( SEL )selector_;


@end
