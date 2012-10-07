#ifndef __JFF_CAST_FUNCTIONS_H__
#define __JFF_CAST_FUNCTIONS_H__

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark NSObject casts
template < class DESTINATION >
DESTINATION* objc_kind_of_cast(id nsObject)
{
    if (nil == nsObject) {
        return nil;
    }
    
    Class destinationClass = [DESTINATION class];
    if (![nsObject isKindOfClass:destinationClass]) {
        NSLog(@"[!!!ERROR!!!] objc_kind_of_cast class mismatch. Expected : %@. Received : %@",
              destinationClass,
              [nsObject class]);
        return nil;
    }
    
    return (DESTINATION *)nsObject;
}


template < class DESTINATION >
DESTINATION* objc_member_of_cast( id nsObject )
{
    if (nil == nsObject) {
        return nil;
    }
    
    Class destinationClass = [DESTINATION class];
    if (![nsObject isMemberOfClass:destinationClass]) {
        NSLog(@"[!!!ERROR!!!] objc_member_of_cast class mismatch. Expected : %@. Received : %@",
              destinationClass,
              [nsObject class]);
        return nil;
    }
    
    return (DESTINATION*)nsObject;
}

template < class DESTINATION >
DESTINATION* objc_dynamic_cast(id nsObject)
{
    return objc_kind_of_cast<DESTINATION>(nsObject);
}

template < class DESTINATION >
DESTINATION *objc_reinterpret_cast(id nsObject)
{
    return (DESTINATION *)nsObject;
}

#endif //__JFF_CAST_FUNCTIONS_H__
