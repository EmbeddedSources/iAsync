#import <Foundation/Foundation.h>

@interface NSMutableSet (DownloadManager)

+(void)addDownloadedFileWithPath:( NSString* )path_;

+(BOOL)containsDownloadedFileWithPath:( NSString* )file_path_;
+(void)removeDownloadedFileWithPath:( NSString* )path_;

@end
