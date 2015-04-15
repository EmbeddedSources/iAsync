@interface JULoadMoreCellscalculatorTest : GHTestCase
@end

@implementation JULoadMoreCellscalculatorTest

- (void)testIndexPathBuilderProducesNil
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    NSArray *received = 0;
    
    {
        cellsCalc.currentCount = 25;
        received = [cellsCalc prepareIndexPathEntriesForBottomCells:0];
        
        GHAssertNil(received, @"Nil expected");
    }
}

- (void)testIndexPathBuilderProducesCorrectItemsCount
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    NSArray *received = 0;
    
    {
        received = [cellsCalc prepareIndexPathEntriesForBottomCells:288];
        GHAssertTrue([received count] == 288, @" An array should contain 288 elements ");
    }
    
    {
        cellsCalc.currentCount = 25;
        received = [cellsCalc prepareIndexPathEntriesForBottomCells:7];
        
        GHAssertTrue([received count] == 7, @" An array should contain 7 elements ");
    }
}

- (void)testIndexPathBuilderProducesCorrectItems
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    NSArray *received = 0;
    
    {
        cellsCalc.currentCount = 25;
        received = [cellsCalc prepareIndexPathEntriesForBottomCells:7];
        
        GHAssertTrue([received count] == 7, @" An array should contain 7 elements ");
        
        NSIndexPath *item = received[0];
        GHAssertTrue(item.row == 26, @" First item does not match ");
        
        item = [received lastObject];
        GHAssertTrue(item.row == 32, @" Last item does not match ");
        
        for (NSUInteger i = 1; i < 7; ++i) {
            
            NSIndexPath *current = received[i    ];
            NSIndexPath *prev    = received[i - 1];
            
            GHAssertTrue(prev.row + 1 == current.row, @"Monotonous rule mismatch");
        }
    }
    
    {
        cellsCalc.currentCount = 0;
        received = [cellsCalc prepareIndexPathEntriesForBottomCells:39];
        
        GHAssertTrue([received count] == 39, @" An array should contain 39 elements ");
        
        NSIndexPath *item = received[0];
        GHAssertTrue(item.row == 1, @" First item does not match ");
        
        item = [received lastObject];
        GHAssertTrue(item.row == 39, @" Last item does not match ");
        
        for (NSUInteger i = 1; i < 39; ++i)
        {
            NSIndexPath *current = received[i    ];
            NSIndexPath *prev    = received[i - 1];
            
            GHAssertTrue(prev.row + 1 == current.row, @"Monotonous rule mismatch");
        }
    }
}

- (void)testElementsAreNotLoaded
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    cellsCalc.currentCount = 25;
    cellsCalc.pageSize     = 20;
    cellsCalc.totalElementsCount = -1;
    
    NSIndexPath *indexPath = nil;
    BOOL isOverflow = NO;
    NSUInteger received = 0;
    
    {
        indexPath = [NSIndexPath indexPathForRow:26
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 ==received, @"Method should return zero");
        GHAssertFalse(isOverflow, @"Unexpected overflow");
    }
    
    cellsCalc.totalElementsCount = 0;
    
    {
        indexPath = [NSIndexPath indexPathForRow:26
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 ==received, @"Method should return zero");
        GHAssertFalse(isOverflow, @"Unexpected overflow");
    }
}

- (void)testAllElementsAreLoaded
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    cellsCalc.currentCount = 25;
    cellsCalc.pageSize     = 20;
    cellsCalc.totalElementsCount = 25;
    
    NSIndexPath *indexPath = nil;
    BOOL isOverflow = NO;
    NSUInteger received = 0;
    
    {
        indexPath = [NSIndexPath indexPathForRow:26
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 ==received, @"Method should return zero");
        GHAssertTrue(isOverflow, @"Unexpected overflow");
    }
    
    {
        indexPath = [NSIndexPath indexPathForRow:10
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 == received, @"Method should return zero");
        GHAssertTrue(isOverflow, @"Unexpected overflow");
    }
    
    {
        indexPath = [NSIndexPath indexPathForRow:33
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 == received, @"Method should return zero");
        GHAssertTrue(isOverflow, @"Unexpected overflow");
    }
}

- (void)testIndexPathPlusPageSizeBiggerTotalCount
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    NSIndexPath *indexPath = nil;
    BOOL isOverflow = NO;
    
    NSUInteger received = 0;
    
    {
        cellsCalc.currentCount = 25;
        cellsCalc.totalElementsCount = 1239;
        cellsCalc.pageSize = 25;
        indexPath = [NSIndexPath indexPathForRow:1224
                                       inSection:0];
        
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        GHAssertTrue(1200 == received, @"Load more button is not required anymore. It is 1213, not 1214 ");
        GHAssertFalse(isOverflow, @"Unexpected overflow");
        
        NSArray *indexPath = [cellsCalc prepareIndexPathEntriesForBottomCells:received];
        
        NSIndexPath *first = indexPath[0];
        NSIndexPath *last  = [indexPath lastObject];
        
        GHAssertTrue(first.row == 26  , @"First row mismatch");
        GHAssertTrue(last.row  == 1225, @"Last  row mismatch");
    }
    
    {
        cellsCalc.currentCount = 25;
        cellsCalc.pageSize = 20;
        cellsCalc.totalElementsCount = 35;
        
        indexPath = [NSIndexPath indexPathForRow:26
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        GHAssertTrue(9 == received, @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount");
        GHAssertTrue(isOverflow, @"Unexpected overflow" );
    }
    
    {
        cellsCalc.currentCount = 50;
        cellsCalc.pageSize     = 10;
        cellsCalc.totalElementsCount = 60;
        indexPath =  [NSIndexPath indexPathForRow:51
                                        inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        GHAssertTrue(9 == received , @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount");
        GHAssertTrue(isOverflow, @"Unexpected overflow" );
    }
    
    {
        cellsCalc.currentCount    = 1240;
        cellsCalc.pageSize        = 25;
        cellsCalc.totalElementsCount = 1241;
        indexPath = [NSIndexPath indexPathForRow:1240
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        GHAssertTrue(0 == received, @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount");
        GHAssertTrue(isOverflow, @"Unexpected overflow" );
    }
}

- (void)testIndexPathPlusPageSizeLessThanTotalCount
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    cellsCalc.currentCount = 25;
    cellsCalc.pageSize     = 5;
    cellsCalc.totalElementsCount = 50;
    
    NSIndexPath *indexPath = nil;
    BOOL isOverflow = NO;
    
    NSUInteger received = 0;
    {
        indexPath = [NSIndexPath indexPathForRow:33
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(10 == received , @"Main scenario, should work correct");
        
        NSArray *indexPath = [cellsCalc prepareIndexPathEntriesForBottomCells:received];
        
        NSIndexPath *first = indexPath[0];
        NSIndexPath *last = [indexPath lastObject];
        
        GHAssertTrue(first.row == 26, @"First row mismatch" );
        GHAssertTrue(last.row  == 35, @"Last  row mismatch" );
    }
    
    {
        indexPath = [NSIndexPath indexPathForRow:28
                                       inSection:0];
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(5 == received, @"Main scenario, should work correct");
        GHAssertFalse(isOverflow, @"Unexpected overflow");
    }
}

- (void)testIndexPathLowestThanCurrentCount
{
    JULoadMoreCellscalculator *cellsCalc = [JULoadMoreCellscalculator new];
    cellsCalc.currentCount = 25;
    cellsCalc.pageSize = 20;
    cellsCalc.totalElementsCount = 35;
    
    NSIndexPath *indexPath = nil;
    BOOL isOverflow = NO;
    
    NSUInteger received = 0;
    {
        indexPath = [NSIndexPath indexPathForRow:6
                                       inSection:0];
        
        received = [cellsCalc suggestElementsToAddCountForIndexPath:indexPath
                                                    overflowOccured:&isOverflow];
        
        GHAssertTrue(0 == received, @"If value of row less than currentCount we should return zero");
        GHAssertFalse(isOverflow, @"Unexpected overflow" );
    }
}

@end
