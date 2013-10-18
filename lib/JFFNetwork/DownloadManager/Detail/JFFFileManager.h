#import <Foundation/Foundation.h>

@interface JFFFileManager : NSObject

+ (FILE *)createFileForPath:(NSString *)path;

+ (BOOL)removeFileForPath:(NSString *)path;

@end
