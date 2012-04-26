#import "NSObject+JFFAlertButton.h"

#import "JFFAlertButton.h"

@implementation NSObject (JFFAlertButton)

-(JFFAlertButton*)toAlertButton
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

@end

@implementation NSString (JFFAlertButton)

-(JFFAlertButton*)toAlertButton
{
   return [ JFFAlertButton alertButton: self action: ^void( void ){} ];
}

@end

@implementation JFFAlertButton (JFFAlertButton)

-(JFFAlertButton*)toAlertButton
{
   return self;
}

@end
