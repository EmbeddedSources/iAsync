#include "JFFMemoryMgmt.h"

id jff_retainAutorelease(id object)
{
    return [[object retain] autorelease];
}

id jff_retain(id object)
{
    return [object retain];
}
