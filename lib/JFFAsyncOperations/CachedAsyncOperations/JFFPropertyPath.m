#import "JFFPropertyPath.h"

@implementation JFFPropertyPath

-(id)initWithName:( NSString* )name_
              key:( id< NSCopying, NSObject > )key_
{
    self = [ super init ];

    if ( self )
    {
        self->_name = name_;
        self->_key  = key_;
    }

    return self;
}

-(NSString*)description
{
    return [ NSString stringWithFormat: @"<JFFPropertyPath name: %@ key: %@>", self.name, self.key ];
}

@end
