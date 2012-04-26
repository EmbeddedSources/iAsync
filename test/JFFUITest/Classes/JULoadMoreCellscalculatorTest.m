@interface JULoadMoreCellscalculatorTest : GHTestCase 
@end

@implementation JULoadMoreCellscalculatorTest

-(void)testIndexPathBuilderProducesNil
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
    NSArray* received_ = 0;

    {
        cells_calc_.currentCount = 25;
        received_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: 0 ];

        GHAssertNil( received_, @"Nil expected" );
    }
}

-(void)testIndexPathBuilderProducesCorrectItemsCount
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
    NSArray* received_ = 0;

    {
        received_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: 288 ];
        GHAssertTrue( [ received_ count ] == 288, @" An array should contain 288 elements " );
    }

    {
        cells_calc_.currentCount = 25;
        received_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: 7 ];

        GHAssertTrue( [ received_ count ] == 7, @" An array should contain 7 elements " );
    }
}

-(void)testIndexPathBuilderProducesCorrectItems
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
    NSArray* received_ = 0;

    {
        cells_calc_.currentCount = 25;
        received_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: 7 ];

        GHAssertTrue( [ received_ count ] == 7, @" An array should contain 7 elements " );

        NSIndexPath* item_ = [ received_ objectAtIndex: 0 ];
        GHAssertTrue( item_.row == 26, @" First item does not match " );

        item_ = [ received_ lastObject ];
        GHAssertTrue( item_.row == 32, @" Last item does not match " );

        for ( NSUInteger i = 1; i < 7; ++i )
        {
            NSIndexPath* current_ = [ received_ objectAtIndex: i     ];
            NSIndexPath* prev_    = [ received_ objectAtIndex: i - 1 ];

            GHAssertTrue( prev_.row + 1 == current_.row, @"Monotonous rule mismatch" );
        }
    }

    {
        cells_calc_.currentCount = 0;
        received_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: 39 ];

        GHAssertTrue( [ received_ count ] == 39, @" An array should contain 39 elements " );

        NSIndexPath* item_ = [ received_ objectAtIndex: 0 ];
        GHAssertTrue( item_.row == 1, @" First item does not match " );

        item_ = [ received_ lastObject ];
        GHAssertTrue( item_.row == 39, @" Last item does not match " );

        for ( NSUInteger i = 1; i < 39; ++i )
        {
            NSIndexPath* current_ = [ received_ objectAtIndex: i     ];
            NSIndexPath* prev_    = [ received_ objectAtIndex: i - 1 ];

            GHAssertTrue( prev_.row + 1 == current_.row, @"Monotonous rule mismatch" );
        }
    }
}


-(void)testElementsAreNotLoaded
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
    cells_calc_.currentCount = 25;
    cells_calc_.pageSize = 20;
    cells_calc_.totalElementsCount = -1;

    NSIndexPath* index_path_ = nil;
    BOOL is_overflow_ = NO;
    NSUInteger received_ = 0;   

    {
        index_path_ = [ NSIndexPath indexPathForRow: 26 
                                            inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];


        GHAssertTrue( 0 ==received_ , @"Method should return zero" );
        GHAssertFalse( is_overflow_, @"Unexpected overflow" );
    }

    cells_calc_.totalElementsCount = 0;

    {
        index_path_ = [ NSIndexPath indexPathForRow: 26 
                                          inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];
      

        GHAssertTrue( 0 ==received_ , @"Method should return zero" );
        GHAssertFalse( is_overflow_, @"Unexpected overflow" );
    }
}

-(void)testAllElementsAreLoaded
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
    cells_calc_.currentCount = 25;
    cells_calc_.pageSize = 20;
    cells_calc_.totalElementsCount = 25;


    NSIndexPath* index_path_ = nil;
    BOOL is_overflow_ = NO;
    NSUInteger received_ = 0;   

    {
        index_path_ = [ NSIndexPath indexPathForRow: 26 
                                          inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];
      

        GHAssertTrue( 0 ==received_ , @"Method should return zero" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }

    {
        index_path_ = [ NSIndexPath indexPathForRow: 10 
                                          inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];
      

        GHAssertTrue( 0 == received_ , @"Method should return zero" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }
   
    {
        index_path_ = [ NSIndexPath indexPathForRow: 33 
                                          inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];
      

        GHAssertTrue( 0 == received_ , @"Method should return zero" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }   
}

-(void)testIndexPathPlusPageSizeBiggerTotalCount
{
    JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];  
    NSIndexPath* index_path_ = nil;
    BOOL is_overflow_ = NO;

    NSUInteger received_ = 0;


    {
        cells_calc_.currentCount = 25;
        cells_calc_.totalElementsCount = 1239;
        cells_calc_.pageSize = 25;
        index_path_ = [ NSIndexPath indexPathForRow: 1224 
                                          inSection: 0 ];

        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_];
        GHAssertTrue( 1200 == received_ , @"Load more button is not required anymore. It is 1213, not 1214 " );
        GHAssertFalse( is_overflow_, @"Unexpected overflow" );

        NSArray* index_path_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: received_ ];

        NSIndexPath* first_ = [ index_path_ objectAtIndex: 0 ];
        NSIndexPath* last_  = [ index_path_ lastObject       ];

        GHAssertTrue( first_.row == 26  , @"First row mismatch" );
        GHAssertTrue( last_.row  == 1225, @"Last  row mismatch" );
    }   

    {
        cells_calc_.currentCount = 25;
        cells_calc_.pageSize = 20;
        cells_calc_.totalElementsCount = 35;

        index_path_ = [ NSIndexPath indexPathForRow: 26 
                                          inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_];
        GHAssertTrue( 9 == received_ , @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }

    {
        cells_calc_.currentCount = 50;
        cells_calc_.pageSize = 10;
        cells_calc_.totalElementsCount = 60;
        index_path_ =  [ NSIndexPath indexPathForRow: 51 
                                           inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_];
        GHAssertTrue( 9 == received_ , @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }


    {
        cells_calc_.currentCount    = 1240;
        cells_calc_.pageSize        = 25;
        cells_calc_.totalElementsCount = 1241;
        index_path_ = [ NSIndexPath indexPathForRow: 1240 
                                        inSection: 0 ];
        received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                        overflowOccured: &is_overflow_ ];
        GHAssertTrue( 0 == received_ , @"If IndexPath plus PageSize bigger totalCount we should return value up to totalCount" );
        GHAssertTrue( is_overflow_, @"Unexpected overflow" );
    }
}

-(void)testIndexPathPlusPageSizeLessThanTotalCount
{
   JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
   cells_calc_.currentCount = 25;
   cells_calc_.pageSize = 5;
   cells_calc_.totalElementsCount = 50;

   NSIndexPath* index_path_ = nil;
   BOOL is_overflow_ = NO;

   NSUInteger received_ = 0;
   {
      index_path_ = [ NSIndexPath indexPathForRow: 33 
                                        inSection: 0 ];
      received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                      overflowOccured: &is_overflow_ ];

      GHAssertTrue( 10 == received_ , @"Main scenario, should work correct" );

      NSArray* index_path_ = [ cells_calc_ prepareIndexPathEntriesForBottomCells: received_ ];

      NSIndexPath* first_ = [ index_path_ objectAtIndex: 0 ];
      NSIndexPath* last_  = [ index_path_ lastObject       ];

      GHAssertTrue( first_.row == 26, @"First row mismatch" );
      GHAssertTrue( last_.row  == 35, @"Last  row mismatch" );
   }

   {
      index_path_ = [ NSIndexPath indexPathForRow: 28 
                                        inSection: 0 ];
      received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                      overflowOccured: &is_overflow_ ];

      GHAssertTrue( 5 == received_, @"Main scenario, should work correct" );
      GHAssertFalse( is_overflow_, @"Unexpected overflow" );
   }
}

-(void)testIndexPathLowestThanCurrentCount
{
   JULoadMoreCellscalculator* cells_calc_ = [ [ JULoadMoreCellscalculator alloc ] init ];
   cells_calc_.currentCount = 25;
   cells_calc_.pageSize = 20;
   cells_calc_.totalElementsCount = 35;

   NSIndexPath* index_path_ = nil;
   BOOL is_overflow_ = NO;

   NSUInteger received_ = 0;
   {
      index_path_ = [ NSIndexPath indexPathForRow: 6 
                                        inSection: 0 ];

      received_ = [ cells_calc_ suggestElementsToAddCountForIndexPath: index_path_
                                                      overflowOccured: &is_overflow_ ];

      GHAssertTrue( 0 == received_ , @"If value of row less than currentCount we should return zero" );
      GHAssertFalse( is_overflow_, @"Unexpected overflow" );
   }
}

@end

