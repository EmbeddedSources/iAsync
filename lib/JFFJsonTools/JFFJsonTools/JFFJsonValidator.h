#import <JFFJsonTools/JFFOptionalObjectField.h>

#import <Foundation/Foundation.h>

#define jOptional(object) ([JFFOptionalObjectField newOptionalObjectFieldWithFieldKey:object])

@interface JFFJsonObjectValidator : NSObject

+ (BOOL)validateJsonObject:(id)jsonObject
           withJsonPattern:(id)jsonPattern
                     error:(NSError *__autoreleasing *)outError;

@end
