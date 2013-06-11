#import <Foundation/Foundation.h>

@interface JFFFileManager : NSObject

+ (FILE *)createFileForPath:(NSString *)path_;

+ (BOOL)removeFileForPath:(NSString *)path_;

@end
