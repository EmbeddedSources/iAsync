#import <Foundation/Foundation.h>

@interface JFFOptionalObjectFieldValue : NSObject

@property (nonatomic, readonly) id fieldValue;

+ (instancetype)newOptionalObjectFieldWithFieldValue:(id)fieldValue;

@end

