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

-(NSArray*)prepareIndexPathEntriesForBottomCells:( NSUInteger )cellsCount_;
-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )indexPath_
                                   overflowOccured:( BOOL* )isOverflow_;
-(NSUInteger)suggestElementsToAddCountForIndex:( NSUInteger )index_
                               overflowOccured:( BOOL* )outIsOverflow_;

@property ( nonatomic, readonly ) BOOL hasNoElements;
@property ( nonatomic, readonly ) BOOL allElementsLoaded;
@property ( nonatomic, readonly ) NSIndexPath* loadMoreIndexPath;

-(BOOL)isLoadMoreIndexPath:( NSIndexPath* )indexPath_;

-(NSInteger)currentCountToStartWith:( NSInteger )totalElementsCount_;

+(NSArray*)defaultUpdateScopeForIndex:( NSUInteger )index_;


-(void)autoLoadingScrollTableView:( id<JUTableViewHolder> )tableViewHolder_
                 toRowAtIndexPath:( NSIndexPath* )indexPath_ 
                 atScrollPosition:( UITableViewScrollPosition )scrollPosition_ 
                         animated:( BOOL )animated_;

@end
