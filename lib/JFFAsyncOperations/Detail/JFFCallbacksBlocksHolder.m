#import "JFFCallbacksBlocksHolder.h"

@implementation JFFCallbacksBlocksHolder

-(id)initWithOnProgressBlock:( JFFAsyncOperationProgressHandler )onProgressBlock_
               onCancelBlock:( JFFCancelAsyncOperationHandler )onCancelBlock_
            didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
{
    self = [ super init ];

    if ( self )
    {
        self.onProgressBlock  = onProgressBlock_;
        self.onCancelBlock    = onCancelBlock_;
        self.didLoadDataBlock = didLoadDataBlock_;
    }

    return self;
}

@end
