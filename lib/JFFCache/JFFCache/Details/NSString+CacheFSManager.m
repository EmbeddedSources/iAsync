#import "NSString+CacheFSManager.h"

@implementation NSString (CacheFSManager)

- (NSString *)cacheDBFileLinkPathWithFolder:(NSString *)folder
{
    NSString *result = [folder stringByAppendingPathComponent:self];
    return result;
}

- (void)cacheDBFileLinkRemoveFileWithFolder:(NSString *)folder
{
    NSString *path = [self cacheDBFileLinkPathWithFolder:folder];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)cacheDBFileLinkSaveData:(NSData *)data
                         folder:(NSString *)folder
{
    NSString *path = [self cacheDBFileLinkPathWithFolder:folder];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    [data writeToURL:url atomically:NO];
    [path addSkipBackupAttribute];
}

- (NSData *)cacheDBFileLinkDataWithFolder:(NSString *)folder
{
    NSString *path = [self cacheDBFileLinkPathWithFolder:folder];
    NSData *result = [[NSData alloc] initWithContentsOfFile:path];
    
    return result;
}

@end
