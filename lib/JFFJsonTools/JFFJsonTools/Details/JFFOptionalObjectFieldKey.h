#import <Foundation/Foundation.h>

@interface JFFOptionalObjectFieldKey : NSObject<NSCopying>

@property (nonatomic, readonly, copy) id fieldKey;

+ (id)newOptionalObjectFieldWithFieldKey:(id)fieldKey;

@end

