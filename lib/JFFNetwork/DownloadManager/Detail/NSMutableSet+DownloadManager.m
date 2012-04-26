#import "NSMutableSet+DownloadManager.h"

#import "JFFFileManager.h"

@implementation NSMutableSet (DownloadManager)

+(NSString*)storePathForDownloadedFiles
{
    return [ NSString documentsPathByAppendingPathComponent: @"JFFDownloadedFiles.data" ];
}

+(id)setWithDownloadedFiles
{
    NSString* storePathForDownloadedFiles_ = [ self storePathForDownloadedFiles ];
    NSArray* downloadedItems_ = [ [ NSArray alloc ] initWithContentsOfFile: storePathForDownloadedFiles_ ];
    return [ [ self alloc ] initWithArray: downloadedItems_ ];
}

-(void)writeToFileDownloadedFiles
{
    NSString* storePathForDownloadedFiles_ = [ [ self class ] storePathForDownloadedFiles ];
    [ [ self allObjects ] writeToFile: storePathForDownloadedFiles_ atomically: YES ];
}

-(void)addDownloadedFileWithPath:( NSString* )filePath_
{
    [ self addObject: filePath_ ];
    [ self writeToFileDownloadedFiles ];
}

-(void)removeDownloadedFileWithPath:( NSString* )filePath_
{
    [ JFFFileManager removeFileForPath: filePath_ ];
    [ self removeObject: filePath_ ];
    [ self writeToFileDownloadedFiles ];
}

-(BOOL)containsDownloadedFileWithPath:( NSString* )filePath_
{
    BOOL result_ = [ self containsObject: filePath_ ];
    if ( result_ && ![ [ NSFileManager defaultManager ] fileExistsAtPath: filePath_ ] )
    {
        [ self removeDownloadedFileWithPath: filePath_ ];
        return NO;
    }
    return result_;
}

+(void)addDownloadedFileWithPath:( NSString* )filePath_
{
    [ [ self setWithDownloadedFiles ] addDownloadedFileWithPath: filePath_ ];
}

+(BOOL)containsDownloadedFileWithPath:( NSString* )filePath_
{
    return [ [ self setWithDownloadedFiles ] containsDownloadedFileWithPath: filePath_ ];
}

+(void)removeDownloadedFileWithPath:( NSString* )filePath_
{
    [ [ self setWithDownloadedFiles ] removeDownloadedFileWithPath: filePath_ ];
}

@end
