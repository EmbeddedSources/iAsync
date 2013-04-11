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

-(void)dealloc
{
    [ self disableMock];
    
    self->_connectionClass = Nil;
    self->_realImpl = NULL;
    self->_mockImpl = NULL;
    self->_realMethod = NULL;
    
}

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(id)initWithConnectionClass:( Class )connectionClass
                      action:( JFFSimpleBlock )action
         executeOriginalImpl:( BOOL )executeOriginalImpl
{
    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }
    
 
    NSParameterAssert( [ connectionClass conformsToProtocol: @protocol(JNUrlConnection) ] );
    NSParameterAssert( nil != action );
    
    action = [ action copy ];
    
    //save args
    {
        self->_shouldInvokeOriginalMethod = executeOriginalImpl;
        self->_connectionClass = connectionClass;
    }
    
    
    //save "real" methods
    {
        self->_realSel    = @selector(start);
        self->_realMethod = class_getInstanceMethod( connectionClass, self->_realSel );
        self->_realImpl   = method_getImplementation( self->_realMethod );
    }

    //create a mock
    {
        SEL start_ = self->_realSel;
        NSImplBlock newAction = nil;
        if ( executeOriginalImpl )
        {
            newAction = ^void( id connectionSelf )
            {
                action();
                self->_realImpl( connectionSelf, start_ );
            };
        }
        else
        {
            newAction = ^void( id connectionSelf )
            {
                action();
            };
        }
        self->_mockImpl = imp_implementationWithBlock( newAction );
        NSParameterAssert( NULL != self->_mockImpl );
    }


    return self;
}

-(void)enableMock
{
    if ( self->_isMockEnabled )
    {
        return;
    }
    
    method_setImplementation( self->_realMethod, self->_mockImpl );
    self->_isMockEnabled = YES;
}

-(void)disableMock
{
    if ( !self->_isMockEnabled )
    {
        return;
    }

    method_setImplementation( self->_realMethod, self->_realImpl );
    self->_isMockEnabled = NO;
}

@end
