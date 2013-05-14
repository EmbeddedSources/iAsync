#import "JFFRemoveButton.h"

#import "JFFRemoveButtonDelegate.h"

@implementation JFFRemoveButton

+ (id)removeButtonWithUserInfo:(NSDictionary *)user_info_
{
    JFFRemoveButton *button = [ self buttonWithType: UIButtonTypeCustom ];
    button.userInfo = user_info_;
    
    UIImage *removeImage = [UIImage imageNamed:@"ESRemoveIcon.png"];
    
    button.frame = CGRectMake( -removeImage.size.width / 3.f, -removeImage.size.height / 3.f
                              , removeImage.size.width, removeImage.size.height );
    
    [button setImage: removeImage
            forState: UIControlStateNormal ];
    
    [button addTarget:button
               action:@selector( removeAction: )
     forControlEvents:UIControlEventTouchUpInside ];
    
    return button;
}

- (void)removeAction:( id )sender_
{
    [ self.delegate didTapRemoveButton: self
                          withUserInfo: self.userInfo ];
}

@end
