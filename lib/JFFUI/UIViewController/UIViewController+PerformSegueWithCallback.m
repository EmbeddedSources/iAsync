#import "UIViewController+PerformSegueWithCallback.h"

static char performSegueCallbackKey;

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

@implementation UIViewController (PerformSegueWithCallback)

- (JFFPerformSegueCallback)performSegueCallback
{
    return objc_getAssociatedObject(self, &performSegueCallbackKey);
}

- (void)setPerformSegueCallback:(JFFPerformSegueCallback)callback
{
    objc_setAssociatedObject(self, &performSegueCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

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
