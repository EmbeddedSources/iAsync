#import "NSMutableDictionary+DownloadingFileInfo.h"

@implementation NSMutableDictionary (DownloadingFileInfo)

+ (NSString *)storePathForDownloadFilesInfo
{
    return [NSString documentsPathByAppendingPathComponent:@"JFFDownloadFilesInfo.data"];
}

+ (NSMutableDictionary *)dictionaryWithDownloadFilesInfo
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithContentsOfFile:[self storePathForDownloadFilesInfo]];
    return result?:[NSMutableDictionary new];
}

- (void)writeToFileDownloadFilesInfo
{
    [self writeToFile:[[self class] storePathForDownloadFilesInfo] atomically:NO];
}

+ (unsigned long long)fileLengthForDestinationURL:(NSURL *)url
{
    NSMutableDictionary *dict = [self dictionaryWithDownloadFilesInfo];
    
    NSNumber *fileLength = dict[[url absoluteString]];
    
    unsigned long long result = fileLength
    ?[fileLength unsignedLongLongValue]
    :(unsigned long long)NSURLResponseUnknownLength;
    
    return result;
}

+ (void)setFileLength:(unsigned long long)fileLength
    forDestinationURL:(NSURL *)url
{
    NSMutableDictionary *dict = [self dictionaryWithDownloadFilesInfo];
    
    dict[[url absoluteString]] = @(fileLength);
    
    [dict writeToFileDownloadFilesInfo];
}

@end
