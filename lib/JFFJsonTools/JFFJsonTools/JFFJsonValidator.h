#import <Foundation/Foundation.h>

@interface JFFJsonObjectValidator : NSObject

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
                     error:(NSError *__autoreleasing *)outError;

@end
