#import <Foundation/Foundation.h>

@interface NSString (CacheFSManager)

-(void)cacheDBFileLinkRemoveFile;
-(void)cacheDBFileLinkSaveData:( NSData* )data_;
-(NSData*)cacheDBFileLinkData;

@end
