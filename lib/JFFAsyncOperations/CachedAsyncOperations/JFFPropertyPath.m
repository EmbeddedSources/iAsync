#import "JFFPropertyPath.h"

@implementation JFFPropertyPath

- (id)initWithName:(NSString *)name
               key:(id< NSCopying, NSObject >)key
{
    self = [ super init ];
    
    if (self) {
        self->_name = name;
        self->_key  = key;
    }
    
    return self;
}

-(NSString*)description
{
    return [[NSString alloc] initWithFormat:@"<JFFPropertyPath name: %@ key: %@>",
            self.name,
            self.key ];
}

@end
