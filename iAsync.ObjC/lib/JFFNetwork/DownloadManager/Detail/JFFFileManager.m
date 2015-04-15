#import "JFFFileManager.h"

@implementation JFFFileManager

+ (FILE *)createFileForPath:(NSString *)path
{
    [[NSFileManager defaultManager ] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:nil];
    return fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a");
}

+ (void)removeAllEmptyFolders:(NSString *)dirPath
{
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    if ([filenames count] == 0) {
       
        if (![[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil])
            return;
        [self removeAllEmptyFolders:[dirPath stringByDeletingLastPathComponent]];
    }
}

+ (BOOL)removeFileForPath:(NSString *)path
{
    if (!path)
        return NO;
    
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    if (result) {
        
        [self removeAllEmptyFolders:[path stringByDeletingLastPathComponent]];
    }
    
    return result;
}

@end
