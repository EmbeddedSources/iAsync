#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TestClassWithProperties : NSObject

@property ( nonatomic, retain ) NSMutableDictionary* dict;

@end

@implementation TestClassWithProperties

@synthesize dict = _dict;

-(void)dealloc
{
    [ _dict release ];

    [ super dealloc ];
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        _dict = [ NSMutableDictionary new ];
    }

    return self;
}

@end

@interface CachedAsyncOperationsTest : GHTestCase
@end

@implementation CachedAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testCachedAsyncOperationsCancel
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* nativeLoader_ = [ JFFAsyncOperationManager new ];

        JFFPropertyPath* propertyPath_ = [ [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                                key: @"1" ] autorelease ];

        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ [ JFFPropertyExtractor new ] autorelease ];
        };

        TestClassWithProperties* dataOwner_ = [ TestClassWithProperties new ];

        @autoreleasepool
        {
            JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                               propertyExtractorFactoryBlock: factory_
                                                                              asyncOperation: nativeLoader_.loader
                                                                      didFinishLoadDataBlock: nil ];

            __block BOOL cancelFlag_ = NO;
            JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
            {
                cancelFlag_ = canceled_;
            };

            JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

            GHAssertFalse( nativeLoader_.finished  , @"OK" );
            GHAssertFalse( nativeLoader_.canceled  , @"OK" );
            GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

            cancel_( YES );

            GHAssertFalse( nativeLoader_.finished  , @"OK" );
            GHAssertTrue ( nativeLoader_.canceled  , @"OK" );
            GHAssertTrue ( nativeLoader_.cancelFlag, @"OK" );

            GHAssertTrue( cancelFlag_, @"OK" );
        }

        [ dataOwner_ release ];
        [ nativeLoader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsUnsibscribe
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

       JFFPropertyPath* propertyPath_ = [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                             key: @"1" ];

        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ [ JFFPropertyExtractor new ] autorelease ];
        };

        TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

        JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                           propertyExtractorFactoryBlock: factory_
                                                                          asyncOperation: nativeLoader_.loader
                                                                  didFinishLoadDataBlock: nil ];

        __block BOOL cancelFlag_ = YES;
        JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
        {
            cancelFlag_ = canceled_;
        };

        JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertFalse( nativeLoader_.canceled  , @"OK" );
        GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

        cancel_( NO );

        GHAssertFalse( nativeLoader_.finished  , @"OK" );
        GHAssertFalse( nativeLoader_.canceled  , @"OK" );
        GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

        GHAssertFalse( cancelFlag_, @"OK" );
        cancelFlag_ = YES;

        nativeLoader_.loaderCancelBlock.onceCancelBlock( NO );

        GHAssertTrue( cancelFlag_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsCancelNative
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

      JFFPropertyPath* propertyPath_ = [ [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                              key: @"1" ] autorelease ];

      JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
      {
         return [ [ JFFPropertyExtractor new ] autorelease ];
      };

      TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

      JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                         propertyExtractorFactoryBlock: factory_
                                                                        asyncOperation: nativeLoader_.loader
                                                                didFinishLoadDataBlock: nil ];

      __block BOOL cancelFlag_ = NO;
      JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
      {
         cancelFlag_ = canceled_;
      };

      JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertFalse( nativeLoader_.canceled  , @"OK" );
      GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

      nativeLoader_.loaderCancelBlock.onceCancelBlock( YES );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertTrue( nativeLoader_.canceled  , @"OK" );
      GHAssertTrue( nativeLoader_.cancelFlag, @"OK" );

      GHAssertTrue( cancelFlag_, @"OK" );
      cancelFlag_ = NO;

      cancel_( YES );

      GHAssertFalse( cancelFlag_, @"OK" );
   }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsUnsibscribeNative
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

      JFFPropertyPath* propertyPath_ = [ [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                              key: @"1" ] autorelease ];

      JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
      {
         return [ [ JFFPropertyExtractor new ] autorelease ];
      };

      TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

      JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                         propertyExtractorFactoryBlock: factory_
                                                                        asyncOperation: nativeLoader_.loader
                                                                didFinishLoadDataBlock: nil ];

      __block BOOL cancelFlag_ = YES;
      JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL canceled_ )
      {
         cancelFlag_ = canceled_;
      };

      JFFCancelAsyncOperation cancel_ = cachedLoader_( nil, cancel_callback_, nil );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertFalse( nativeLoader_.canceled  , @"OK" );
      GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

      nativeLoader_.loaderCancelBlock.onceCancelBlock( NO );

      GHAssertFalse( nativeLoader_.finished  , @"OK" );
      GHAssertTrue( nativeLoader_.canceled  , @"OK" );
      GHAssertFalse( nativeLoader_.cancelFlag, @"OK" );

      GHAssertFalse( cancelFlag_, @"OK" );
      cancelFlag_ = YES;

      cancel_( NO );

      GHAssertTrue( cancelFlag_, @"OK" );
   }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCachedAsyncOperationsOnceLoading
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

      JFFPropertyPath* propertyPath_ = [ [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                              key: @"1" ] autorelease ];

      JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
      {
         return [ [ JFFPropertyExtractor new ] autorelease ];
      };

      TestClassWithProperties* dataOwner_ = [ [ TestClassWithProperties new ] autorelease ];

      JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                         propertyExtractorFactoryBlock: factory_
                                                                        asyncOperation: nativeLoader_.loader
                                                                didFinishLoadDataBlock: nil ];

      GHAssertTrue( nativeLoader_.loadingCount == 0, @"OK" );

      __block BOOL finished1_ = NO;
      cachedLoader_( nil, nil, ^( id result_, NSError* error_ )
      {
         finished1_ = result_ != nil;
      } );

      __block BOOL finished2_ = NO;
      cachedLoader_( nil, nil, ^( id result_, NSError* error_ )
      {
         finished2_ = result_ != nil;
      } );

      JFFAsyncOperation cachedLoader2_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                          propertyExtractorFactoryBlock: factory_
                                                                         asyncOperation: nativeLoader_.loader
                                                                 didFinishLoadDataBlock: nil ];
      __block BOOL finished3_ = NO;
      cachedLoader2_( nil, nil, ^( id result_, NSError* error_ )
      {
         finished3_ = result_ != nil;
      } );

      GHAssertFalse( nativeLoader_.finished, @"OK" );
      GHAssertTrue( nativeLoader_.loadingCount == 1, @"OK" );
      GHAssertFalse( finished1_, @"OK" );
      GHAssertFalse( finished2_, @"OK" );
      GHAssertFalse( finished3_, @"OK" );

      GHAssertTrue( [ dataOwner_.dict objectForKey: @"1" ] == nil, @"OK" );

      id result_ = [ NSNull null ];
      nativeLoader_.loaderFinishBlock.didFinishBlock( result_, nil );

      GHAssertTrue( nativeLoader_.finished, @"OK" );
      GHAssertTrue( finished1_, @"OK" );
      GHAssertTrue( finished2_, @"OK" );
      GHAssertTrue( finished3_, @"OK" );

      GHAssertTrue( [ dataOwner_.dict objectForKey: @"1" ] == result_, @"OK" );
   }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

//Scenario:
//1. Create property loader
//2. Wrap it by unsubscribe on dealloc
//3. Release owner
//4. Finish loader -> crash
//Result - should not crach
-(void)testUnsubscribeBug
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* nativeLoader_ = [ [ JFFAsyncOperationManager new ] autorelease ];

      JFFPropertyPath* propertyPath_ = [ [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                              key: @"1" ] autorelease ];

      JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
      {
         return [ [ JFFPropertyExtractor new ] autorelease ];
      };

      __block BOOL deallocated_ = NO;
      @autoreleasepool
      {
         @autoreleasepool
         {
            TestClassWithProperties* dataOwner_ = [ TestClassWithProperties new ];

            JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                               propertyExtractorFactoryBlock: factory_
                                                                              asyncOperation: nativeLoader_.loader
                                                                      didFinishLoadDataBlock: nil ];

            JFFAsyncOperation  unsubscribeLoader_ = [ dataOwner_ autoUnsubsribeOnDeallocAsyncOperation: cachedLoader_ ];

            [ dataOwner_ addOnDeallocBlock: ^()
            {
               deallocated_ = YES;
            } ];

            [ dataOwner_ release ];

            unsubscribeLoader_( nil, nil, nil );
         }

         nativeLoader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
      }
      GHAssertTrue( deallocated_, @"OK" );
   }
   
   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
