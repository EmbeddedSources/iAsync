#import "JFFCallbacksBlocksHolder.h"

@implementation JFFCallbacksBlocksHolder

- (instancetype)initWithOnProgressBlock:(JFFAsyncOperationProgressHandler)onProgressBlock
                          onCancelBlock:(JFFCancelAsyncOperationHandler)onCancelBlock
                       didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
{
    self = [super init];
    
    if (self) {
        
        _onProgressBlock  = [onProgressBlock  copy];
        _onCancelBlock    = [onCancelBlock    copy];
        _didLoadDataBlock = [didLoadDataBlock copy];
    }
    
    return self;
}

@end
