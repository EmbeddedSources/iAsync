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
   return result_ ? result_ : [ NSMutableDictionary dictionary ];
}

-(void)writeToFileDownloadFilesInfo
{
   [ self writeToFile: [ [ self class ] storePathForDownloadFilesInfo ] atomically: NO ];
}

+(unsigned long long)fileLengthForDestinationURL:( NSURL* )url_
{
   NSMutableDictionary* dict_ = [ self dictionaryWithDownloadFilesInfo ];

   NSNumber* file_length_ = [ dict_ objectForKey: [ url_ absoluteString ] ];
   if ( file_length_ )
   {
      return [ file_length_ unsignedLongLongValue ];
   }
   return NSURLResponseUnknownLength;
}

+(void)setFileLength:( unsigned long long )file_length_
   forDestinationURL:( NSURL* )url_
{
   NSMutableDictionary* dict_ = [ self dictionaryWithDownloadFilesInfo ];

   NSNumber* file_length_number_ = [ NSNumber numberWithUnsignedLongLong: file_length_ ];
   [ dict_ setObject: file_length_number_ forKey: [ url_ absoluteString ] ];

   [ dict_ writeToFileDownloadFilesInfo ];
}

@end
