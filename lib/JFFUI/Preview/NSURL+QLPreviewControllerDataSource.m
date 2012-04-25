#import "NSURL+QLPreviewControllerDataSource.h"

@implementation NSURL (QLPreviewControllerDataSource)

-(NSInteger)numberOfPreviewItemsInPreviewController:( QLPreviewController* )controller_
{
   return 1;
}

-(id<QLPreviewItem>)previewController:( QLPreviewController* )controller_
                   previewItemAtIndex:( NSInteger )index_
{
   NSAssert1( 0 == index_, @"Unexpected index range %d", index_ );
   return self;
}

@end
