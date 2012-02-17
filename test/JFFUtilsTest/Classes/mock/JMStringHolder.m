#import "JMStringHolder.h"

@implementation JMStringHolder

@synthesize content = _content;

-(void)dealloc
{
   [ _content release ];
   [ super dealloc ];
}

@end
