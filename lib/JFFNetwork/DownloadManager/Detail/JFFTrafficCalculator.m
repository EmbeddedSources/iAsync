#import "JFFTrafficCalculator.h"

#import "JFFTrafficCalculatorDelegate.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFDownloadedBytesPerDate : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSUInteger bytesCount;

@end

@implementation JFFDownloadedBytesPerDate

- (instancetype)initWithBytesCount:(NSUInteger)bytesCount
{
    self = [super init];
    
    if (self) {
        
        _date       = [NSDate new];
        _bytesCount = bytesCount;
    }

    return self;
}


@end

@implementation JFFTrafficCalculator
{
    NSMutableArray *_downloadingSpeedInfo;
    __unsafe_unretained id< JFFTrafficCalculatorDelegate > _delegate;
    JFFScheduler *_scheduler;
}

- (instancetype)initWithDelegate:(id<JFFTrafficCalculatorDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        
        _delegate = delegate;
        _downloadingSpeedInfo = [NSMutableArray new];
    }
    
    return self;
}

- (void)removeOldItemsFromDownloadingSpeedInfo
{
    static NSTimeInterval averageSpeedDuration = 3.0;
    
    JFFDownloadedBytesPerDate *lastItem = [_downloadingSpeedInfo lastObject];
    while (lastItem &&
           ([[NSDate new] timeIntervalSince1970] - [lastItem.date timeIntervalSince1970] > averageSpeedDuration))
    {
        [_downloadingSpeedInfo removeLastObject];
        lastItem = [_downloadingSpeedInfo lastObject];
    }
}

- (void)calculateDownloadSpeed
{
    [self removeOldItemsFromDownloadingSpeedInfo];
    
    float speed = 0.f;
    
    if ([_downloadingSpeedInfo count] > 1) {
        
        NSRange range = {0, [_downloadingSpeedInfo count] - 1};
        NSArray *arrayExcludeLast = [_downloadingSpeedInfo subarrayWithRange:range];
        
        NSUInteger donloadedBytes = 0;
        for (JFFDownloadedBytesPerDate *item in arrayExcludeLast) {
            
            donloadedBytes += item.bytesCount;
        }
        
        JFFDownloadedBytesPerDate *firstItem = arrayExcludeLast[0];
        NSDate *lastDate = ([arrayExcludeLast count] == 1)?[NSDate new]:firstItem.date;

        JFFDownloadedBytesPerDate *lastItem = [arrayExcludeLast lastObject];
        
        NSTimeInterval timeDiff = ([lastDate timeIntervalSince1970] - [lastItem.date timeIntervalSince1970]);
        NSTimeInterval result = donloadedBytes / timeDiff;
        
        speed = (float)result;
    }
    
    [_delegate trafficCalculator:self didChangeDownloadSpeed:speed];
}

- (void)stop
{
    _scheduler = nil;
    
    _downloadingSpeedInfo = [NSMutableArray new];
    [self calculateDownloadSpeed];
}

- (void)bytesReceived:(NSUInteger)bytesCount
{
    JFFDownloadedBytesPerDate *item = [[JFFDownloadedBytesPerDate alloc] initWithBytesCount:bytesCount];
    [_downloadingSpeedInfo insertObject:item atIndex:0];
    
    [self removeOldItemsFromDownloadingSpeedInfo];
}

- (void)startLoading
{
    __unsafe_unretained JFFTrafficCalculator* weakSelf = self;
    JFFScheduledBlock block = ^void(JFFCancelScheduledBlock cancel) {
        
        [weakSelf calculateDownloadSpeed];
    };
    
    _scheduler = [JFFScheduler new];
    [_scheduler addBlock:block duration:1. leeway:.2];
}

@end
