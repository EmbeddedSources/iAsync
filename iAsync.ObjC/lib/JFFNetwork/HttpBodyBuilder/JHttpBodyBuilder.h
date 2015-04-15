#import <Foundation/Foundation.h>

@interface JHttpBodyBuilder : NSObject

+ (NSString *)tmpFileForUploadStreamWithDataForFilePath:(NSString *)dataFilePath
                                               boundary:(NSString *)boundary
                                                   name:(NSString *)name
                                               fileName:(NSString *)fileName
                                          dictWithParam:(NSDictionary *)dictWithParam;

@end
