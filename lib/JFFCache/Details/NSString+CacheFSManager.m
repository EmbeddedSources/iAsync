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

-(void)cacheDBFileLinkSaveData:( NSData* )data_
{
    NSString* path_ = [ self cacheDBFileLinkPath ];
    NSURL* url_ = [ [ NSURL alloc ] initFileURLWithPath: path_ isDirectory: NO ];
    [ data_ writeToURL: url_ atomically: NO ];
    [ path_ addSkipBackupAttribute ];
}

-(NSData*)cacheDBFileLinkData
{
    NSString* path_ = [ self cacheDBFileLinkPath ];
    NSData* result_ = [ [ NSData alloc ] initWithContentsOfFile: path_ ];

    return result_;
}

@end
