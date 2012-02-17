#import "JFFAsyncOperationProgressBlockHolder.h"

@implementation JFFAsyncOperationProgressBlockHolder

@synthesize progressBlock;

-(void)performProgressBlockWithArgument:( id )progress_info_
{
   if ( self.progressBlock )
      self.progressBlock( progress_info_ );
}

@end
