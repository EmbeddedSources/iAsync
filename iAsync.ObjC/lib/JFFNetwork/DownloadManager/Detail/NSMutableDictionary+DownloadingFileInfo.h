#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DownloadingFileInfo)

+ (unsigned long long)fileLengthForDestinationURL:(NSURL *)url;

+ (void)setFileLength:(unsigned long long)fileLength
    forDestinationURL:(NSURL *)url;

@end
