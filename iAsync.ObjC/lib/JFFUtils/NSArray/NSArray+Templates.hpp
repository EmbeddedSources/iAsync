#ifndef JFFUtils_NSArray_Templates_hpp
#define JFFUtils_NSArray_Templates_hpp

#include <vector>
#import <Foundation/Foundation.h>

namespace JFFUtils
{
    template < class T, class Alloc = std::allocator<T> >
    void NSArrayToVector( NSArray* objcResult_, std::vector< T, Alloc >& result_ )
    {
        result_.clear();
        result_.reserve( [ objcResult_ count ] );
        
        for ( T item_ in objcResult_ )
        {
            result_.push_back( item_ );
        }
    }
}

#endif
