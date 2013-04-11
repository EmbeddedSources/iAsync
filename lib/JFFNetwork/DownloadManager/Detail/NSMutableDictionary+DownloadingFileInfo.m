#import "NSMutableDictionary+DownloadingFileInfo.h"

#import <JFFUtils/NSString/NSString+PathExtensions.h>

@implementation NSMutableDictionary (DownloadingFileInfo)

+ (NSString *)storePathForDownloadFilesInfo
{
    return [NSString documentsPathByAppendingPathComponent:@"JFFDownloadFilesInfo.data"];
}

+(NSMutableDictionary*)dictionaryWithDownloadFilesInfo
{
    NSMutableDictionary *result_ = [ NSMutableDictionary dictionaryWithContentsOfFile: [ self storePathForDownloadFilesInfo ] ];
    return result_ ?: [NSMutableDictionary new];
}

-(void)writeToFileDownloadFilesInfo
{
    [ self writeToFile: [ [ self class ] storePathForDownloadFilesInfo ] atomically: NO ];
}

+ (unsigned long long)fileLengthForDestinationURL:(NSURL *)url_
{
    NSMutableDictionary *dict_ = [ self dictionaryWithDownloadFilesInfo ];
    
    NSNumber *fileLength = dict_[ [ url_ absoluteString ] ];
    if ( fileLength )
    {
        return [ fileLength unsignedLongLongValue ];
    }
    return NSURLResponseUnknownLength;
}

+ (void)setFileLength:( unsigned long long )fileLength_
    forDestinationURL:( NSURL* )url_
{
    NSMutableDictionary* dict_ = [ self dictionaryWithDownloadFilesInfo ];

    dict_[ [ url_ absoluteString ] ] = @( fileLength_ );

    [ dict_ writeToFileDownloadFilesInfo ];
}

@end
