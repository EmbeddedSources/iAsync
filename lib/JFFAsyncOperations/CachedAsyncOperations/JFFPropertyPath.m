#import "JFFPropertyPath.h"

@implementation JFFPropertyPath

- (instancetype)initWithName:(NSString *)name
                         key:(id<NSCopying, NSObject>)key
{
    self = [super init];
    
    if (self) {
        _name = name;
        _key  = key;
    }
    
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"<JFFPropertyPath name: %@ key: %@>",
            self.name,
            self.key];
}

@end
