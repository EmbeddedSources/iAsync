#import "JFFAsyncTools.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationInterface.h"

#import "JFFFileDescriptorReaderError.h"

#include <sys/stat.h>

@interface JFFAsyncFileReader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFileReader
{
    dispatch_source_t _inputSrc;
    char *_readBuffer;
@public
    JFFFileHendlerBuilder _handleBuilder;
    dispatch_queue_t _queue;
}

- (void)dealloc
{
    
}

//https://developer.apple.com/library/ios/DOCUMENTATION/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finnishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    _readBuffer = NULL;
    
    uintptr_t handle = _handleBuilder();
    
    int result = fcntl(handle, F_SETFL, O_NONBLOCK);
    //FILE	* stream = fdopen(handle, "r");
    
    if (result == -1) {
        
        if (finnishCallback)
            finnishCallback(nil, [JFFFileDescriptorReaderError new]);
        return;
    }
    
    _inputSrc = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, handle, 0, _queue);
    
    //TODO implement lseek
    
//    dispatch_connect();
//    dispatch_read();
    
    dispatch_source_set_event_handler(_inputSrc, ^{
        
        //process_input(my_file);
        
        unsigned long availableToRead = dispatch_source_get_data(_inputSrc);
        
        _readBuffer = reallocf(_readBuffer, availableToRead);
        
        if (_readBuffer == NULL) {
            
            ///TODO change error
            if (finnishCallback)
                finnishCallback(nil, [JFFFileDescriptorReaderError new]);
            return;
        }
        
        ssize_t result = read(handle, _readBuffer, availableToRead);
        
        if (result < 0) {
            
            ///TODO change error
            if (finnishCallback)
                finnishCallback(nil, [JFFFileDescriptorReaderError new]);
            return;
        }
        
        if (progressCallback && result > 0) {
            
            NSData *chunk = [NSData dataWithBytesNoCopy:_readBuffer length:result];
            progressCallback(chunk);
        }
        
        FILE *f = fdopen(handle, "r");
        if (feof(f)) {
            
            if (finnishCallback)
                finnishCallback(@YES, nil);
            return;
        }
        
        off_t offset = lseek(handle, 0, SEEK_CUR);
        
        if (offset == EOF) {
            
            if (finnishCallback)
                finnishCallback(@YES, nil);
        }
        
        {
            struct stat buf;
            fstat(handle, &buf);
            int size = buf.st_size;
            
            if (size == offset) {
                
                if (finnishCallback)
                    finnishCallback(@YES, nil);
            }
        }

        
//        if (feof(stream)) {
//            
//            if (finnishCallback)
//                finnishCallback(@YES, nil);
//        }
    });
    
    dispatch_source_set_cancel_handler(_inputSrc,  ^{
        
        //fclose(stream);
        close(handle);
        
        if (_readBuffer != NULL) {
            free(_readBuffer);
            _readBuffer = NULL;
        }
    });
    
    dispatch_resume(_inputSrc);
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    switch (task) {
        case JFFAsyncOperationHandlerTaskUnsubscribe:
        {
            break;
        }
        case JFFAsyncOperationHandlerTaskCancel:
        {
            dispatch_source_cancel(_inputSrc);
            break;
        }
        case JFFAsyncOperationHandlerTaskResume:
        {
            dispatch_resume(_inputSrc);
            break;
        }
        case JFFAsyncOperationHandlerTaskSuspend:
        {
            dispatch_suspend(_inputSrc);
            break;
        }
        default:
        {
            NSAssert1(NO, @"unsupported task: %lu", (unsigned long)task);
            break;
        }
    }
}

@end

JFFAsyncOperation jFileDescriptorReader(JFFFileHendlerBuilder handleBuilder,
                                        dispatch_queue_t queue)
{
    handleBuilder = [handleBuilder copy];
    
    id<JFFAsyncOperationInterface> (^factory)(void) = ^id<JFFAsyncOperationInterface>(void) {
        
        JFFAsyncFileReader *result = [JFFAsyncFileReader new];
        
        if (result) {
            
            result->_handleBuilder = handleBuilder;
            result->_queue         = queue;
        }
        
        return result;
    };
    
    return buildAsyncOperationWithAdapterFactoryWithDispatchQueue(factory, queue);
}
