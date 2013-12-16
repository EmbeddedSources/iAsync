#import <Foundation/Foundation.h>

@interface JFFOptionalObjectFieldKey : NSObject<NSCopying>

@property (nonatomic, readonly, copy) id fieldKey;

+ (instancetype)newOptionalObjectFieldWithFieldKey:(id)fieldKey;

@end

