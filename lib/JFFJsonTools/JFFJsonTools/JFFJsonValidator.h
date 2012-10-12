#import <Foundation/Foundation.h>

id jOptionalKey(id object);
id jOptionalValue(id object);

@interface JFFJsonObjectValidator : NSObject

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
                     error:(NSError *__autoreleasing *)outError;

@end
