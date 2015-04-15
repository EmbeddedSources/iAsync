#import "UIViewController+PerformSegueWithCallback.h"

@interface UIViewControllerPrepareForSegueHook : NSObject
@end

@implementation UIViewControllerPrepareForSegueHook

- (JFFPerformSegueCallback)performSegueCallback
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setPerformSegueCallback:(JFFPerformSegueCallback)callback
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)prepareForSegueOriginal:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)prepareForSeguePrototype:(UIStoryboardSegue *)segue sender:(id)sender
{
    JFFPerformSegueCallback callback = self.performSegueCallback;
    if (callback) {
        self.performSegueCallback = nil;
        callback(segue);
    }
    
    if ([self respondsToSelector:@selector(prepareForSegueOriginal:sender:)]) {
        [self prepareForSegueOriginal:segue sender:sender];
    }
}

@end

@interface UIViewController (PerformSegueWithCallback_Properties)

@property (copy, nonatomic) JFFPerformSegueCallback performSegueCallback;

@end

@implementation UIViewController (PerformSegueWithCallback_Properties)

@dynamic performSegueCallback;

+ (void)load
{
    jClass_implementProperty(self, NSStringFromSelector(@selector(performSegueCallback)));
}

@end

@implementation UIViewController (PerformSegueWithCallback)

- (void)performSegueWithIdentifier:(NSString *)identifier
                            sender:(id)sender
                          callback:(JFFPerformSegueCallback)callback
{
    self.performSegueCallback = callback;
    [self performSegueWithIdentifier:identifier sender:sender];
}

+ (void)load
{
    [[UIViewControllerPrepareForSegueHook class] hookInstanceMethodForClass:[UIViewController class]
                                                               withSelector:@selector(prepareForSegue:sender:)
                                                    prototypeMethodSelector:@selector(prepareForSeguePrototype:sender:)
                                                         hookMethodSelector:@selector(prepareForSegueOriginal:sender:)];
}

@end
