#ifndef JFF_UTILS_JFF_MEMORY_MGMT_HEADER_INCLUDED
#define JFF_UTILS_JFF_MEMORY_MGMT_HEADER_INCLUDED

#include <objc/objc.h>

#ifdef __cplusplus
extern "C" {
#endif

id jff_retainAutorelease( id object_ );
id jff_retain( id object_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif //JFF_UTILS_JFF_MEMORY_MGMT_HEADER_INCLUDED
