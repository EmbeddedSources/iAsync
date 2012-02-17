#import "NSMutableSet+DownloadManager.h"

#import "JFFFileManager.h"

#import <JFFUtils/NSString/NSString+PathExtensions.h>

@implementation NSMutableSet (DownloadManager)

+(NSString*)storePathForDownloadedFiles
{
   return [ NSString documentsPathByAppendingPathComponent: @"JFFDownloadedFiles.data" ];
}

+(id)setWithDownloadedFiles
{
   return [ self setWithArray: [ NSArray arrayWithContentsOfFile: [ self storePathForDownloadedFiles ] ] ];
}

-(void)writeToFileDownloadedFiles
{
   [ [ self allObjects ] writeToFile: [ [ self class ] storePathForDownloadedFiles ] atomically: YES ];
}

-(void)addDownloadedFileWithPath:( NSString* )file_path_
{
   [ self addObject: file_path_ ];
   [ self writeToFileDownloadedFiles ];
}

-(void)removeDownloadedFileWithPath:( NSString* )file_path_
{
   [ JFFFileManager removeFileForPath: file_path_ ];
   [ self removeObject: file_path_ ];
   [ self writeToFileDownloadedFiles ];
}

-(BOOL)containsDownloadedFileWithPath:( NSString* )file_path_
{
   BOOL result_ = [ self containsObject: file_path_ ];
   if ( result_ && ![ [ NSFileManager defaultManager ] fileExistsAtPath: file_path_ ] )
   {
      [ self removeDownloadedFileWithPath: file_path_ ];
      return NO;
   }
   return result_;
}

+(void)addDownloadedFileWithPath:( NSString* )file_path_
{
   [ [ self setWithDownloadedFiles ] addDownloadedFileWithPath: file_path_ ];
}

+(BOOL)containsDownloadedFileWithPath:( NSString* )file_path_
{
   return [ [ self setWithDownloadedFiles ] containsDownloadedFileWithPath: file_path_ ];
}

+(void)removeDownloadedFileWithPath:( NSString* )file_path_
{
   [ [ self setWithDownloadedFiles ] removeDownloadedFileWithPath: file_path_ ];
}

@end
