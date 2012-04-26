#import "JFFFileManager.h"

#import <JFFUtils/NSString/NSString+PathExtensions.h>

#include <sys/types.h>
#include <sys/stat.h>

@implementation JFFFileManager

+(FILE*)createFileForPath:( NSString* )path_
{
   [ [ NSFileManager defaultManager ] createDirectoryAtPath: [ path_ stringByDeletingLastPathComponent ]
                                withIntermediateDirectories: YES
                                                 attributes: nil
                                                      error: nil ];
   return fopen( [ path_ cStringUsingEncoding: NSASCIIStringEncoding ], "a" );
}

+(void)removeAllEmptyFolders:( NSString* )dir_path_
{
   NSArray* filenames_ = [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: dir_path_ error: nil ];
   if ( [ filenames_ count ] == 0 )
   {
      if ( ![ [ NSFileManager defaultManager ] removeItemAtPath: dir_path_ error: nil ] )
         return;
      [ self removeAllEmptyFolders: [ dir_path_ stringByDeletingLastPathComponent ] ];
   }
}

+(BOOL)removeFileForPath:( NSString* )path_
{
   if ( !path_ )
      return NO;

   BOOL result_ = [ [ NSFileManager defaultManager ] removeItemAtPath: path_ error: nil ];
   if ( result_ )
   {
      [ self removeAllEmptyFolders: [ path_ stringByDeletingLastPathComponent ] ];
   }

   return result_;
}

@end
