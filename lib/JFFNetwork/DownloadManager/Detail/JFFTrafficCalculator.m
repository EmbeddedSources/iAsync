#import "JFFTrafficCalculator.h"

#import "JFFTrafficCalculatorDelegate.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFDownloadedBytesPerDate : NSObject

@property ( nonatomic ) NSDate* date;
@property ( nonatomic ) NSUInteger bytesCount;

@end

@implementation JFFDownloadedBytesPerDate

- (instancetype)initWithBytesCount:( NSUInteger )bytesCount_
{
    self = [super init];
    
    if (self) {
        
        _date       = [NSDate new];
        _bytesCount = bytesCount_;
    }

    return self;
}


@end

@implementation JFFTrafficCalculator
{
    NSMutableArray* _downloadingSpeedInfo;
    __unsafe_unretained id< JFFTrafficCalculatorDelegate > _delegate;
    JFFScheduler* _scheduler;
}

- (instancetype)initWithDelegate:(id<JFFTrafficCalculatorDelegate>)delegate_
{
    self = [ super init ];

    if ( self )
    {
        _delegate = delegate_;
        _downloadingSpeedInfo = [ NSMutableArray new ];
    }

    return self;
}

- (void)removeOldItemsFromDownloadingSpeedInfo
{
    static NSTimeInterval average_speed_duration_ = 3.0;

    JFFDownloadedBytesPerDate* lastItem_ = [ _downloadingSpeedInfo lastObject ];
    while ( lastItem_ &&
           ( [ [ NSDate new ] timeIntervalSince1970 ] - [ lastItem_.date timeIntervalSince1970 ] > average_speed_duration_ ) )
    {
        [ _downloadingSpeedInfo removeLastObject ];
        lastItem_ = [ _downloadingSpeedInfo lastObject ];
    }
}

- (void)calculateDownloadSpeed
{
    [ self removeOldItemsFromDownloadingSpeedInfo ];

    float speed_ = 0.f;

    if ( [ _downloadingSpeedInfo count ] > 1 )
    {
        NSRange range_ = { 0, [ _downloadingSpeedInfo count ] - 1 };
        NSArray* arrayExcludeLast_ = [ _downloadingSpeedInfo subarrayWithRange: range_ ];

        NSUInteger donloadedBytes_ = 0;
        for ( JFFDownloadedBytesPerDate* item_ in arrayExcludeLast_ )
        {
            donloadedBytes_ += item_.bytesCount;
        }

        JFFDownloadedBytesPerDate* firstItem_ = arrayExcludeLast_[ 0 ];
        NSDate* lastDate_ = ( [ arrayExcludeLast_ count ] == 1 ) ? [ NSDate new ] : firstItem_.date;

        JFFDownloadedBytesPerDate* lastItem_ = [ arrayExcludeLast_ lastObject ];
        speed_ = (float) donloadedBytes_ /
            ( [ lastDate_ timeIntervalSince1970 ] - [ lastItem_.date timeIntervalSince1970 ] );
    }

    [ _delegate trafficCalculator: self didChangeDownloadSpeed: speed_ ];
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
