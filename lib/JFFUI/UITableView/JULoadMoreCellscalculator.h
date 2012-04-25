#import <Foundation/Foundation.h>

@class UITableView;

@protocol JUTableViewHolder <NSObject>

@required
-(UITableView*)tableView;
-(NSInteger)currentCount;
-(void)setCurrentCount:( NSInteger )count_;

@end

@interface JULoadMoreCellscalculator : NSObject

@property ( nonatomic, assign ) NSInteger currentCount;
@property ( nonatomic, assign ) NSUInteger pageSize;
@property ( nonatomic, assign ) NSUInteger totalElementsCount;

@property ( nonatomic, assign, readonly ) BOOL       isPagingDisabled;
@property ( nonatomic, assign, readonly ) BOOL       isPagingEnabled ;
@property ( nonatomic, assign, readonly ) NSUInteger numberOfRows    ;

-(NSArray*)prepareIndexPathEntriesForBottomCells:( NSUInteger )cells_count_;
-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                   overflowOccured:( BOOL* )is_overflow_;
-(NSUInteger)suggestElementsToAddCountForIndex:( NSUInteger )index_
                               overflowOccured:( BOOL* )out_is_overflow_;

@property ( nonatomic, assign, readonly ) BOOL hasNoElements;
@property ( nonatomic, assign, readonly ) BOOL allElementsLoaded;
@property ( nonatomic, retain, readonly ) NSIndexPath* loadMoreIndexPath;
-(BOOL)isLoadMoreIndexPath:( NSIndexPath* )index_path_;

-(NSInteger)currentCountToStartWith:( NSInteger )total_elements_count_;

+(NSArray*)defaultUpdateScopeForIndex:( NSUInteger )index_;


-(void)autoLoadingScrollTableView:( id<JUTableViewHolder> )table_view_holder_
                 toRowAtIndexPath:( NSIndexPath* )index_path_ 
                 atScrollPosition:( UITableViewScrollPosition )scroll_position_ 
                         animated:( BOOL )animated_;

@end
