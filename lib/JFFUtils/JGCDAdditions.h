#ifndef __JFF_GCD_ADDITIONS_INCLUDED__
#define __JFF_GCD_ADDITIONS_INCLUDED__

#include <dispatch/queue.h>

#ifdef __cplusplus
extern "C" {
#endif

void safe_dispatch_sync( dispatch_queue_t queue_, dispatch_block_t block_ );

void safe_dispatch_barrier_sync( dispatch_queue_t queue_, dispatch_block_t block_ );

dispatch_queue_t dispatch_queue_get_or_create(const char *label, dispatch_queue_attr_t attr);

void dispatch_queue_release_by_label( const char *label_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif //__JFF_GCD_ADDITIONS_INCLUDED__
