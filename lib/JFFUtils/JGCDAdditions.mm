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
