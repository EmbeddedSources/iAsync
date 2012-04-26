#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFOnDeallocBlockOwner : NSObject

@property ( nonatomic, copy ) JFFSimpleBlock block;

-(id)initWithBlock:( JFFSimpleBlock )block_;

@end
