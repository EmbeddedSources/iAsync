#import "JFFRuntime.h"

#include <objc/runtime.h>

void enumerateAllClassesWithBlock( void(^block_)( Class ) )
{
    if ( !block_ )
        return;

    int numClasses_ = objc_getClassList( NULL, 0 );
    Class classes_[ sizeof( Class ) * numClasses_ ];

    numClasses_ = objc_getClassList( classes_, numClasses_ );

    for ( int index_ = 0; index_ < numClasses_; ++index_ )
    {
        Class class_ = classes_[ index_ ];
        if ( class_getClassMethod( class_, @selector( conformsToProtocol: ) ) )
            block_( class_ );
    }
}
