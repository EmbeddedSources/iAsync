#include "JGCDAdditions.h"

#import "JFFSharedDispatchersStorage.h"

void safe_dispatch_sync( dispatch_queue_t queue_, dispatch_block_t block_ )
{
    if ( dispatch_get_current_queue() != queue_ )
        dispatch_sync( queue_, block_ );
    else
        block_();
}

void safe_dispatch_barrier_sync( dispatch_queue_t queue_, dispatch_block_t block_ )
{
    if ( dispatch_get_current_queue() != queue_ )
        dispatch_barrier_sync( queue_, block_ );
    else
        block_();
}

dispatch_queue_t
dispatch_queue_get_or_create( const char *label_, dispatch_queue_attr_t attr_ )
{
    return [ JFFSharedDispatchersStorage dispatchQueueGetOrCreate: label_
                                                        attribute: attr_ ];
}
