#import "JFFFileDescriptorReaderError.h"

@implementation JFFFileDescriptorReaderError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_ASYNC_OPERATION_FILE_DESCRIPTOR_ERROR", nil)];
}

@end
