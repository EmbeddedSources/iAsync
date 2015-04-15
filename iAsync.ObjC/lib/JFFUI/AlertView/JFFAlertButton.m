#import "JFFAlertButton.h"

@implementation JFFAlertButton

- (instancetype)initButton:(NSString *)title action:(JFFSimpleBlock)action
{
    self = [super init];
    
    if (self) {
        
        _title  = title;
        _action = action;
    }
    
    return self;
}

+ (instancetype)newAlertButton:(NSString *)title action:(JFFSimpleBlock)action
{
    return [[self alloc] initButton:title action:action];
}

@end
