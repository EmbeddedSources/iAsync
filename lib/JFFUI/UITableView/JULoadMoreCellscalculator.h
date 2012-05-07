#import <Foundation/Foundation.h>

@class UITableView;

@protocol JUTableViewHolder <NSObject>

@required
-(UITableView*)tableView;
-(NSInteger)currentCount;
-(void)setCurrentCount:( NSInteger )count_;

@end

@interface JULoadMoreCellscalculator : NSObject

@property ( nonatomic ) NSInteger currentCount;
@property ( nonatomic ) NSUInteger pageSize;
@property ( nonatomic ) NSUInteger totalElementsCount;

@property ( nonatomic, readonly ) BOOL       isPagingDisabled;
@property ( nonatomic, readonly ) BOOL       isPagingEnabled ;
@property ( nonatomic, readonly ) NSUInteger numberOfRows    ;

-(NSArray*)prepareIndexPathEntriesForBottomCells:( NSUInteger )cells_count_;
-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                   overflowOccured:( BOOL* )is_overflow_;
-(NSUInteger)suggestElementsToAddCountForIndex:( NSUInteger )index_
                               overflowOccured:( BOOL* )out_is_overflow_;

@property ( nonatomic, readonly ) BOOL hasNoElements;
@property ( nonatomic, readonly ) BOOL allElementsLoaded;
@property ( nonatomic, readonly ) NSIndexPath* loadMoreIndexPath;

-(BOOL)isLoadMoreIndexPath:( NSIndexPath* )index_path_;

-(NSInteger)currentCountToStartWith:( NSInteger )total_elements_count_;

+(NSArray*)defaultUpdateScopeForIndex:( NSUInteger )index_;


-(void)autoLoadingScrollTableView:( id<JUTableViewHolder> )table_view_holder_
                 toRowAtIndexPath:( NSIndexPath* )index_path_ 
                 atScrollPosition:( UITableViewScrollPosition )scroll_position_ 
                         animated:( BOOL )animated_;

@end
