#include "JGCDAdditions.h"

#include <map>
#include <string>

static std::map<std::string, dispatch_queue_t> dispatchByLabel;
static NSString *const lockObject = @"0524a0b0-4bc8-47da-a1f5-6073ba5b59d9";

//TODO autoremove mode
dispatch_queue_t dispatch_queue_get_or_create(const char *label, dispatch_queue_attr_t attr)
{
    @synchronized(lockObject) {
        const std::string labelStr(label);
        
        dispatch_queue_t result = dispatchByLabel[labelStr];
        if (result == NULL) {
            result = dispatch_queue_create(label, attr);
            dispatchByLabel[labelStr] = result;
        }
        
        return result;
    }
}

//never call it )))
void dispatch_queue_release_by_label(const char *label)
{
    @synchronized(lockObject) {
        
        dispatchByLabel.erase(label);
    }
}


#pragma mark -
#pragma mark Legacy
void dispatch_sync_check_queue(dispatch_queue_t queue, dispatch_queue_t currentQueue, dispatch_block_t block)
{    
    if (currentQueue != queue) {
        dispatch_sync(queue, block);
    } else {
        block();
    }
}

void dispatch_barrier_sync_check_queue(dispatch_queue_t queue, dispatch_queue_t currentQueue,dispatch_block_t block)
{
    if (currentQueue != queue) {
        dispatch_barrier_sync(queue, block);
    } else {
        block();
    }
}

void safe_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_sync_check_queue(queue, dispatch_get_main_queue(), block);
}

void safe_dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_barrier_sync_check_queue(queue, dispatch_get_main_queue(), block);
}

