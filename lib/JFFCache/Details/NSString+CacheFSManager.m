#import "NSString+CacheFSManager.h"

@implementation NSString (CacheFSManager)

- (NSString *)cacheDBFileLinkPath
{
    NSString *result = [NSString documentsPathByAppendingPathComponent:self];
    return result;
}

- (void)cacheDBFileLinkRemoveFile
{
    NSString *path = [self cacheDBFileLinkPath];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)cacheDBFileLinkSaveData:(NSData *)data
{
    NSString *path = [self cacheDBFileLinkPath];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    [data writeToURL:url atomically:NO];
    [path addSkipBackupAttribute];
}

- (NSData *)cacheDBFileLinkData
{
    NSString *path = [self cacheDBFileLinkPath];
    NSData *result = [[NSData alloc] initWithContentsOfFile:path];
    
    return result;
}

@end
