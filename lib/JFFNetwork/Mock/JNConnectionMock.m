#import "JNConnectionMock.h"


#import "JNUrlConnection.h"
#import <objc/runtime.h>

typedef void (^NSImplBlock)( id self );

@implementation JNConnectionMock
{
    BOOL _shouldInvokeOriginalMethod;
    Class _connectionClass;
    
    IMP _realImpl;
    IMP _mockImpl;
    
    Method _realMethod;
    //Method _mockMethod;

    SEL _realSel;
}

- (void)dealloc
{
    [self disableMock];
    
    _connectionClass = Nil;
    _realImpl   = NULL;
    _mockImpl   = NULL;
    _realMethod = NULL;
    
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithConnectionClass:(Class)connectionClass
                                 action:(JFFSimpleBlock)action
                    executeOriginalImpl:(BOOL)executeOriginalImpl
{
    self = [super init];
    if (nil == self) {
        
        return nil;
    }
    
    NSParameterAssert([connectionClass conformsToProtocol:@protocol(JNUrlConnection)]);
    NSParameterAssert(nil != action);
    
    action = [action copy];
    
    //save args
    {
        _shouldInvokeOriginalMethod = executeOriginalImpl;
        _connectionClass = connectionClass;
    }
    
    //save "real" methods
    {
        _realSel    = @selector(start);
        _realMethod = class_getInstanceMethod(connectionClass, _realSel);
        _realImpl   = method_getImplementation(_realMethod);
    }
    
    //create a mock
    {
        SEL start = _realSel;
        NSImplBlock newAction = nil;
        if (executeOriginalImpl)
        {
            newAction = ^void(id connectionSelf)
            {
                action();
                _realImpl(connectionSelf, start);
            };
        }
        else
        {
            newAction = ^void( id connectionSelf )
            {
                action();
            };
        }
        _mockImpl = imp_implementationWithBlock(newAction);
        NSParameterAssert(NULL != _mockImpl);
    }
    
    return self;
}

- (void)enableMock
{
    if (_isMockEnabled) {
        return;
    }
    
    method_setImplementation(_realMethod, _mockImpl);
    _isMockEnabled = YES;
}

- (void)disableMock
{
    if (!_isMockEnabled) {
        return;
    }
    
    method_setImplementation(_realMethod, _realImpl);
    _isMockEnabled = NO;
}

@end
