#import <Foundation/Foundation.h>

@interface JFFOptionalObjectField : NSObject<NSCopying>

@property (nonatomic, readonly, copy) id fieldKey;

+ (id)newOptionalObjectFieldWithFieldKey:(id)fieldKey;

@end

