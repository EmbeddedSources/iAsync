#import "NSString+CacheFSManager.h"

@implementation NSString (CacheFSManager)

-(NSString*)cacheDBFileLinkPath
{
    NSString* result_ = [ NSString documentsPathByAppendingPathComponent: self ];
    return result_;
}

-(void)cacheDBFileLinkRemoveFile
{
    NSString* path_ = [ self cacheDBFileLinkPath ];
    [ [ NSFileManager defaultManager ] removeItemAtPath: path_ error: nil ];
}

- (void)cacheDBFileLinkSaveData:(NSData *)data
{
    NSString *path = [self cacheDBFileLinkPath];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    [data writeToURL:url atomically:NO];
    [path addSkipBackupAttribute];
}

-(NSData*)cacheDBFileLinkData
{
    NSString* path_ = [ self cacheDBFileLinkPath ];
    NSData* result_ = [ [ NSData alloc ] initWithContentsOfFile: path_ ];

    return result_;
}

@end
