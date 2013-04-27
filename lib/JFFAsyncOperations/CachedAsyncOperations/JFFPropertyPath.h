#import <Foundation/Foundation.h>

@interface JFFPropertyPath : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id<NSCopying, NSObject> key;

- (id)initWithName:(NSString *)name
               key:(id< NSCopying, NSObject >)key;

@end
