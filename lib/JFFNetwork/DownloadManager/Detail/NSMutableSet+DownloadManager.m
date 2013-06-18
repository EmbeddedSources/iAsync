#import "NSMutableSet+DownloadManager.h"

#import "JFFFileManager.h"

@implementation NSMutableSet (DownloadManager)

+ (NSString *)storePathForDownloadedFiles
{
    return [ NSString documentsPathByAppendingPathComponent: @"JFFDownloadedFiles.data" ];
}

+ (id)setWithDownloadedFiles
{
    NSString *storePathForDownloadedFiles = [self storePathForDownloadedFiles];
    NSArray  *downloadedItems = [[NSArray alloc] initWithContentsOfFile:storePathForDownloadedFiles];
    return [[self alloc] initWithArray:downloadedItems];
}

- (void)writeToFileDownloadedFiles
{
    NSString *storePathForDownloadedFiles = [[self class] storePathForDownloadedFiles];
    [[self allObjects] writeToFile:storePathForDownloadedFiles atomically:YES];
}

- (void)addDownloadedFileWithPath:(NSString *)filePath
{
    [self addObject:filePath];
    [self writeToFileDownloadedFiles];
}

- (void)removeDownloadedFileWithPath:(NSString *)filePath
{
    [JFFFileManager removeFileForPath:filePath];
    [self removeObject:filePath];
    [self writeToFileDownloadedFiles];
}

- (BOOL)containsDownloadedFileWithPath:(NSString *)filePath
{
    BOOL result = [self containsObject:filePath];
    if (result && ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self removeDownloadedFileWithPath:filePath];
        return NO;
    }
    return result;
}

+ (void)addDownloadedFileWithPath:( NSString* )filePath_
{
    [ [ self setWithDownloadedFiles ] addDownloadedFileWithPath: filePath_ ];
}

+ (BOOL)containsDownloadedFileWithPath:( NSString* )filePath_
{
    return [ [ self setWithDownloadedFiles ] containsDownloadedFileWithPath: filePath_ ];
}

+ (void)removeDownloadedFileWithPath:( NSString* )filePath_
{
    [ [ self setWithDownloadedFiles ] removeDownloadedFileWithPath: filePath_ ];
}

@end
