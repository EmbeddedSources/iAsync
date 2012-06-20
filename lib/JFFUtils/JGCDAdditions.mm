#include "JGCDAdditions.h"

#include <map>
#include <string>

static std::map< std::string, dispatch_queue_t > dispatchByLabel_;
static NSString* const lockObject_ = @"0524a0b0-4bc8-47da-a1f5-6073ba5b59d9";

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

dispatch_queue_t dispatch_queue_get_or_create( const char *label_, dispatch_queue_attr_t attr_ )
{
    @synchronized( lockObject_ )
    {
        const std::string labelStr_( label_ );

        dispatch_queue_t result_ = dispatchByLabel_[ labelStr_ ];
        if ( result_ == NULL )
        {
            result_ = dispatch_queue_create( label_, attr_ );
            dispatchByLabel_[ labelStr_ ] = result_;
        }

        return result_;
    }
}

void dispatch_queue_release_by_label( const char *label_ )
{
    @synchronized( lockObject_ )
    {
        const std::string labelStr_( label_ );

        auto position_ = dispatchByLabel_.find( labelStr_ );
        if ( position_ != dispatchByLabel_.end() )
        {
            dispatch_queue_t queue_ = position_->second;
            dispatch_release( queue_ );

            dispatchByLabel_.erase( position_ );
        }
    }
}
