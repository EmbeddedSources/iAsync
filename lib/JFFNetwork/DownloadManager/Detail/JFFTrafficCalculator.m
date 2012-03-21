#import "JFFTrafficCalculator.h"

#import "JFFTrafficCalculatorDelegate.h"

#import <JFFScheduler/JFFScheduler.h>

@interface ESDownloadedBytesPerDate : NSObject

//STODO remove
@property ( nonatomic, retain ) NSDate* date;
@property ( nonatomic, assign ) NSUInteger bytesCount;

@end

@implementation ESDownloadedBytesPerDate

@synthesize date = _date;
@synthesize bytesCount = _bytes_count;

-(id)initWithBytesCount:( NSUInteger )bytes_count_
{
   self = [ super init ];

   if ( self )
   {
      self.date = [ NSDate date ];
      self.bytesCount = bytes_count_;
   }

   return self;
}

-(void)dealloc
{
   [ _date release ];

   [ super dealloc ];
}

@end

@interface JFFTrafficCalculator ()

//JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSMutableArray* downloadingSpeedInfo;
@property ( nonatomic, retain ) RICancelCalculateSpeed cancelCalculateSpeedBlock;
@property ( nonatomic, assign ) id< JFFTrafficCalculatorDelegate > delegate;

@end

@implementation JFFTrafficCalculator

@synthesize cancelCalculateSpeedBlock = _cancel_calculate_speed_block;
@synthesize downloadingSpeedInfo = _downloading_speed_info;
@synthesize delegate = _delegate;

-(id)initWithDelegate:( id< JFFTrafficCalculatorDelegate > )delegate_
{
   self = [ super init ];

   if ( self )
   {
      self.delegate = delegate_;
      self.downloadingSpeedInfo = [ NSMutableArray array ];
   }

   return self;
}

-(void)dealloc
{
   if ( _cancel_calculate_speed_block )
      _cancel_calculate_speed_block();
   [ _cancel_calculate_speed_block release ];
   [ _downloading_speed_info release ];

   [ super dealloc ];
}

-(void)stopScheduling
{
   if ( self.cancelCalculateSpeedBlock )
   {
      self.cancelCalculateSpeedBlock();
      self.cancelCalculateSpeedBlock = nil;
   }
}

-(void)removeOldItemsFromDownloadingSpeedInfo
{
   static NSTimeInterval average_speed_duration_ = 3.0;

   ESDownloadedBytesPerDate* last_item_ = [ self.downloadingSpeedInfo lastObject ];
   while ( last_item_ && ( [ [ NSDate date ] timeIntervalSince1970 ] - [ last_item_.date timeIntervalSince1970 ] > average_speed_duration_ ) )
   {
      [ self.downloadingSpeedInfo removeLastObject ];
      last_item_ = [ self.downloadingSpeedInfo lastObject ];
   }
}

-(void)calculateDownloadSpeed
{
   [ self removeOldItemsFromDownloadingSpeedInfo ];

   float speed_ = 0.f;

   if ( [ self.downloadingSpeedInfo count ] > 1 )
   {
      NSRange range_ = NSMakeRange( 0, [ self.downloadingSpeedInfo count ] - 1 );
      NSArray* array_exclude_last_ = [ self.downloadingSpeedInfo subarrayWithRange: range_ ];

      NSUInteger donloaded_bytes_ = 0;
      for ( ESDownloadedBytesPerDate* item_ in array_exclude_last_ )
      {
         donloaded_bytes_ += item_.bytesCount;
      }

      ESDownloadedBytesPerDate* first_item_ = [ array_exclude_last_ objectAtIndex: 0 ];
      NSDate* last_date_ = ( [ array_exclude_last_ count ] == 1 ) ? [ NSDate date ] : first_item_.date;

      ESDownloadedBytesPerDate* last_item_ = [ array_exclude_last_ lastObject ];
      speed_ = (float) donloaded_bytes_ / ( [ last_date_ timeIntervalSince1970 ] - [ last_item_.date timeIntervalSince1970 ] );
   }

   [ self.delegate trafficCalculator: self didChangeDownloadSpeed: speed_ ];
}

-(void)stop
{
   [ self stopScheduling ];

   self.downloadingSpeedInfo = [ NSMutableArray array ];
   [ self calculateDownloadSpeed ];
}

-(void)bytesReceived:( NSUInteger )bytes_count_
{
   ESDownloadedBytesPerDate* item_ = [ [ [ ESDownloadedBytesPerDate alloc ] initWithBytesCount: bytes_count_ ] autorelease ];
   [ self.downloadingSpeedInfo insertObject: item_ atIndex: 0 ];

   [ self removeOldItemsFromDownloadingSpeedInfo ];
}

-(void)startLoading
{
   static NSTimeInterval calculate_speed_interval_ = 1.0;

   [ self stopScheduling ];

   __block typeof(self) self_ = self;
   JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ ) { [ self_ calculateDownloadSpeed ]; };
   self.cancelCalculateSpeedBlock = [ [ JFFScheduler sharedScheduler ] addBlock: block_ duration: calculate_speed_interval_ ];
   
}

@end
