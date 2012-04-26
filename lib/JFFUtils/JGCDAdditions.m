#include "JGCDAdditions.h"

void safe_dispatch_sync( dispatch_queue_t queue_, dispatch_block_t block_ )
{
    if ( dispatch_get_current_queue() != queue_ )
        dispatch_sync( queue_, block_ );
    else
        block_();
}

