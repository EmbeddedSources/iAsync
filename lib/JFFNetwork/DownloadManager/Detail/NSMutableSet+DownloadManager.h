#import <Foundation/Foundation.h>

@interface NSMutableSet (DownloadManager)

+ (void)addDownloadedFileWithPath:(NSString *)path;

+ (BOOL)containsDownloadedFileWithPath:(NSString *)filePath;
+ (void)removeDownloadedFileWithPath:(NSString *)path;

@end
