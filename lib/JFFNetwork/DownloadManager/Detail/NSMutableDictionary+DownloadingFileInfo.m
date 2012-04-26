#import "NSMutableDictionary+DownloadingFileInfo.h"

#import <JFFUtils/NSString/NSString+PathExtensions.h>

@implementation NSMutableDictionary (DownloadingFileInfo)

+(NSString*)storePathForDownloadFilesInfo
{
    return [ NSString documentsPathByAppendingPathComponent: @"JFFDownloadFilesInfo.data" ];
}

+(NSMutableDictionary*)dictionaryWithDownloadFilesInfo
{
    NSMutableDictionary* result_ = [ NSMutableDictionary dictionaryWithContentsOfFile: [ self storePathForDownloadFilesInfo ] ];
    return result_ ?: [ NSMutableDictionary new ];
}

-(void)writeToFileDownloadFilesInfo
{
    [ self writeToFile: [ [ self class ] storePathForDownloadFilesInfo ] atomically: NO ];
}

+(unsigned long long)fileLengthForDestinationURL:( NSURL* )url_
{
    NSMutableDictionary* dict_ = [ self dictionaryWithDownloadFilesInfo ];

    NSNumber* fileLength_ = [ dict_ objectForKey: [ url_ absoluteString ] ];
    if ( fileLength_ )
    {
        return [ fileLength_ unsignedLongLongValue ];
    }
    return NSURLResponseUnknownLength;
}

+(void)setFileLength:( unsigned long long )file_length_
   forDestinationURL:( NSURL* )url_
{
    NSMutableDictionary* dict_ = [ self dictionaryWithDownloadFilesInfo ];

    NSNumber* fileLengthNumber_ = [ NSNumber numberWithUnsignedLongLong: file_length_ ];
    [ dict_ setObject: fileLengthNumber_ forKey: [ url_ absoluteString ] ];

    [ dict_ writeToFileDownloadFilesInfo ];
}

@end
