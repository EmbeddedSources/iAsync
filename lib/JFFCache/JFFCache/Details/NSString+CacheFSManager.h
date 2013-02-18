#import <Foundation/Foundation.h>

@interface NSString (CacheFSManager)

- (NSString *)cacheDBFileLinkPathWithFolder:(NSString *)folder;

- (void)cacheDBFileLinkRemoveFileWithFolder:(NSString *)folder;

- (void)cacheDBFileLinkSaveData:(NSData *)data
                         folder:(NSString *)folder;

- (NSData *)cacheDBFileLinkDataWithFolder:(NSString *)folder;

@end
