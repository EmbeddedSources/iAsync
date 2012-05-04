#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <Foundation/Foundation.h>

typedef void (^TestAsyncRequestBlock)(JFFSimpleBlock);

//GHAsyncTestCase category
@interface NSObject (MainThreadTests)

-(void)performAsyncRequestOnMainThreadWithBlock:( void (^)(JFFSimpleBlock) )block_
                                       selector:( SEL )selector_;


@end
