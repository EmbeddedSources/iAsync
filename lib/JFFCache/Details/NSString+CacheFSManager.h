#import <Foundation/Foundation.h>

@interface NSString (CacheFSManager)

- (void)cacheDBFileLinkRemoveFile;
- (void)cacheDBFileLinkSaveData:(NSData *)data;
- (NSData *)cacheDBFileLinkData;

@end
