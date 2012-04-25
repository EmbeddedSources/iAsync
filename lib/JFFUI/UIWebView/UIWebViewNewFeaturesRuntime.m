
@interface UIWebViewNewFeaturesRuntime : NSObject

@property( nonatomic, readonly, copy ) NSArray* subviews;

@end

@implementation UIWebViewNewFeaturesRuntime

@dynamic subviews;

-(UIScrollView*)scrollView
{
    return [ self.subviews firstMatch: ^BOOL( id subview_ )
    {
        return [ [ subview_ class ] isSubclassOfClass: [ UIScrollView class ] ];
    } ];
}

+(void)load
{
    //for ios 4.x only
    [ self addInstanceMethodIfNeedWithSelector: @selector( scrollView )
                                       toClass: [ NSURL class ] ];
}

@end
