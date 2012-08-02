#import "JFFSimpleBlockHolder.h"

@implementation JFFSimpleBlockHolder

-(void)performBlockOnce
{
   if ( !self.simpleBlock )
      return;

   JFFSimpleBlock block_ = self.simpleBlock;
   self.simpleBlock = nil;
   block_();
}

-(JFFSimpleBlock)onceSimpleBlock
{
   return ^void( void )
   {
      [ self performBlockOnce ];
   };
}

@end
