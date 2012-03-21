//can not be under arc
#import <Foundation/Foundation.h>

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#include <objc/runtime.h>

@interface JFFRuntimeInitializer : NSObject
@end

@implementation JFFRuntimeInitializer

-(void)deallocRemoveAssociatedObjectsHook
{
    [ self doesNotRecognizeSelector: _cmd ];
}

-(void)deallocRemoveAssociatedObjectsPrototype
{
    objc_removeAssociatedObjects( self );

    [ self deallocRemoveAssociatedObjectsHook ];
}

+(void)load
{
    [ self hookInstanceMethodForClass: [ NSObject class ]
                         withSelector: @selector( dealloc )
              prototypeMethodSelector: @selector( deallocRemoveAssociatedObjectsPrototype )
                   hookMethodSelector: @selector( deallocRemoveAssociatedObjectsHook ) ];
}

@end
