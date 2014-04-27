#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

@implementation JFFAsyncOpFinishedByUnsubscriptionError

+ (instancetype)alloc
{
    static JFFAsyncOpFinishedByUnsubscriptionError *instance = nil;
    
    if (!instance) {
        
        instance = [super alloc];
    }
    
    return instance;
}

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_ASYNC_OPERATION_FINISHED_BY_UNSUBSCRIPTION_ERROR", nil)];
}

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.async_unsubscribed.jff_async_operations.library";
}

- (void)writeErrorWithJFFLogger
{
}

@end
