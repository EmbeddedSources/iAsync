#import <Foundation/Foundation.h>

@interface JFFOptionalObjectFieldValue : NSObject

@property (nonatomic, readonly) id fieldValue;

+ (id)newOptionalObjectFieldWithFieldValue:(id)fieldValue;

@end

