#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef uintptr_t (^JFFFileHendlerBuilder)(void);
    
    JFFAsyncOperation jFileDescriptorReader(JFFFileHendlerBuilder handleBuilder,
                                            dispatch_queue_t queue);
    
#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
