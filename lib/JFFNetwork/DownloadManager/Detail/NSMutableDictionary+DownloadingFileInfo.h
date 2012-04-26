#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DownloadingFileInfo)

+(unsigned long long)fileLengthForDestinationURL:( NSURL* )url_;

+(void)setFileLength:( unsigned long long )file_length_
   forDestinationURL:( NSURL* )url_;

@end
