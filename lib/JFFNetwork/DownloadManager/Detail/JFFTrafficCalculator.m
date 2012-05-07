#import "JFFTrafficCalculator.h"

#import "JFFTrafficCalculatorDelegate.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFDownloadedBytesPerDate : NSObject

@property ( nonatomic ) NSDate* date;
@property ( nonatomic ) NSUInteger bytesCount;

@end

@implementation JFFDownloadedBytesPerDate

@synthesize date       = _date;
@synthesize bytesCount = _bytesCount;

-(id)initWithBytesCount:( NSUInteger )bytesCount_
{
    self = [ super init ];

    if ( self )
    {
        _date       = [ NSDate new ];
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

-(id)initWithDelegate:( id< JFFTrafficCalculatorDelegate > )delegate_
{
    self = [ super init ];

    if ( self )
    {
        _delegate = delegate_;
        _downloadingSpeedInfo = [ NSMutableArray new ];
    }

    return self;
}

-(void)removeOldItemsFromDownloadingSpeedInfo
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

-(void)calculateDownloadSpeed
{
    [ self removeOldItemsFromDownloadingSpeedInfo ];

    float speed_ = 0.f;

    if ( [ _downloadingSpeedInfo count ] > 1 )
    {
        NSRange range_ = NSMakeRange( 0, [ _downloadingSpeedInfo count ] - 1 );
        NSArray* arrayExcludeLast_ = [ _downloadingSpeedInfo subarrayWithRange: range_ ];

        NSUInteger donloadedBytes_ = 0;
        for ( JFFDownloadedBytesPerDate* item_ in arrayExcludeLast_ )
        {
            donloadedBytes_ += item_.bytesCount;
        }

        JFFDownloadedBytesPerDate* first_item_ = [ arrayExcludeLast_ objectAtIndex: 0 ];
        NSDate* lastDate_ = ( [ arrayExcludeLast_ count ] == 1 ) ? [ NSDate new ] : first_item_.date;

        JFFDownloadedBytesPerDate* lastItem_ = [ arrayExcludeLast_ lastObject ];
        speed_ = (float) donloadedBytes_ /
            ( [ lastDate_ timeIntervalSince1970 ] - [ lastItem_.date timeIntervalSince1970 ] );
    }

    [ _delegate trafficCalculator: self didChangeDownloadSpeed: speed_ ];
}

-(void)stop
{
    _scheduler = nil;

    _downloadingSpeedInfo = [ NSMutableArray new ];
    [ self calculateDownloadSpeed ];
}

-(void)bytesReceived:( NSUInteger )bytes_count_
{
    JFFDownloadedBytesPerDate* item_ = [ [ JFFDownloadedBytesPerDate alloc ] initWithBytesCount: bytes_count_ ];
    [ _downloadingSpeedInfo insertObject: item_ atIndex: 0 ];

    [ self removeOldItemsFromDownloadingSpeedInfo ];
}

-(void)startLoading
{
    static NSTimeInterval calculateSpeedInterval_ = 1.0;

    __unsafe_unretained JFFTrafficCalculator* self_ = self;
    JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
    {
        [ self_ calculateDownloadSpeed ];
    };

    _scheduler = [ JFFScheduler new ];
    [ _scheduler addBlock: block_ duration: calculateSpeedInterval_ ];
}

@end
