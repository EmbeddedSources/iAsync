#include "JFFMemoryMgmt.h"

id jff_retainAutorelease( id object_ )
{
    return [ [ object_ retain ] autorelease ];
}

id jff_retain( id object_ )
{
    return [ object_ retain ];
}
