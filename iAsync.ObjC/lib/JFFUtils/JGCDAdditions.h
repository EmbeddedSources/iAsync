#ifndef __JFF_GCD_ADDITIONS_INCLUDED__
#define __JFF_GCD_ADDITIONS_INCLUDED__

#include <dispatch/queue.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    dispatch_queue_t dispatch_queue_get_or_create(const char *label, dispatch_queue_attr_t attr);
    
    void dispatch_queue_release_by_label(const char *label);

    
    
    // @adk : for XCTest where dispatch_creqte_queue() returns main queue
    void dispatch_sync_check_queue(dispatch_queue_t queue, dispatch_queue_t currentQueue, dispatch_block_t block);
    void dispatch_barrier_sync_check_queue(dispatch_queue_t queue, dispatch_queue_t currentQueue,dispatch_block_t block);
    
    // @adk : legacy
    void safe_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
    
    void safe_dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block);
    
    
#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif //__JFF_GCD_ADDITIONS_INCLUDED__
