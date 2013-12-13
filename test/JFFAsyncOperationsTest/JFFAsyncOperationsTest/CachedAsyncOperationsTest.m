#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TestClassWithProperties : NSObject

@property (nonatomic) NSMutableDictionary *dict;

@end

@implementation TestClassWithProperties

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _dict = [NSMutableDictionary new];
    }
    
    return self;
}

@end

@interface CachedAsyncOperationsTest : GHTestCase
@end

@implementation CachedAsyncOperationsTest

- (void)setUp
{
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

- (void)testCachedAsyncOperationsCancel
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *nativeLoader = [JFFAsyncOperationManager new];
        
        JFFPropertyPath *propertyPath = [[JFFPropertyPath alloc] initWithName:@"dict" key:@"1"];
        
        JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor *(void) {
            
            return [JFFPropertyExtractor new];
        };
        
        TestClassWithProperties *dataOwner = [TestClassWithProperties new];
        
        @autoreleasepool
        {
            JFFAsyncOperation cachedLoader = [dataOwner asyncOperationForPropertyWithPath:propertyPath
                                                            propertyExtractorFactoryBlock:factory
                                                                           asyncOperation:nativeLoader.loader
                                                                   didFinishLoadDataBlock:nil];
            
            __block NSError *finishError;
            JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
                
                finishError = error;
            };
            
            JFFAsyncOperationHandler cancel = cachedLoader(nil, nil, doneCallback);
            
            GHAssertFalse(nativeLoader.finished, @"OK");
            GHAssertFalse(nativeLoader.canceled, @"OK");
            GHAssertTrue (nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUndefined, @"OK");
            
            cancel(JFFAsyncOperationHandlerTaskCancel);
            
            GHAssertFalse(nativeLoader.finished  , @"OK");
            GHAssertTrue (nativeLoader.canceled  , @"OK");
            GHAssertTrue (nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"OK");
            
            GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], @"OK");
        }
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCachedAsyncOperationsUnsibscribe
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *nativeLoader = [JFFAsyncOperationManager new];
        
        JFFPropertyPath *propertyPath = [[JFFPropertyPath alloc] initWithName:@"dict"
                                                                          key:@"1"];
        
        JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor *(void) {
            
            return [JFFPropertyExtractor new];
        };
        
        TestClassWithProperties *dataOwner = [TestClassWithProperties new];
        
        JFFAsyncOperation cachedLoader = [dataOwner asyncOperationForPropertyWithPath:propertyPath
                                                        propertyExtractorFactoryBlock:factory
                                                                       asyncOperation:nativeLoader.loader
                                                               didFinishLoadDataBlock:nil];
        
        __block NSError *resultError;
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            resultError = error;
        };
        
        JFFAsyncOperationHandler cancel = cachedLoader(nil, nil, doneCallback);
        
        GHAssertFalse(nativeLoader.finished, @"OK");
        GHAssertFalse(nativeLoader.canceled, @"OK");
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUndefined, @"OK");
        
        cancel(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertFalse(nativeLoader.finished  , @"OK");
        GHAssertFalse(nativeLoader.canceled  , @"OK");
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUndefined, @"OK");
        
        GHAssertTrue([resultError isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]], @"OK");
        resultError = nil;
        
        nativeLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertNil(resultError, @"OK");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCachedAsyncOperationsCancelNative
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *nativeLoader = [JFFAsyncOperationManager new];
        
        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc] initWithName:@"dict"
                                                                           key:@"1"];
        
        JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor *(void)
        {
            return [JFFPropertyExtractor new];
        };
        
        TestClassWithProperties *dataOwner = [TestClassWithProperties new];
        
        JFFAsyncOperation cachedLoader = [dataOwner asyncOperationForPropertyWithPath:propertyPath
                                                        propertyExtractorFactoryBlock:factory
                                                                       asyncOperation:nativeLoader.loader
                                                               didFinishLoadDataBlock:nil];
        
        __block NSError *resultError;
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            resultError = error;
        };
        
        JFFAsyncOperationHandler cancel = cachedLoader(nil, nil, doneCallback);
        
        GHAssertFalse(nativeLoader.finished  , @"OK");
        GHAssertFalse(nativeLoader.canceled  , @"OK");
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUndefined, @"OK");
        
        nativeLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertFalse(nativeLoader.finished, @"OK" );
        GHAssertTrue(nativeLoader.canceled , @"OK" );
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"OK" );
        
        GHAssertTrue([resultError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], @"OK");
        resultError = nil;
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertNil(resultError, @"OK");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCachedAsyncOperationsUnsibscribeNative
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *nativeLoader = [JFFAsyncOperationManager new];
        
        JFFPropertyPath *propertyPath = [[JFFPropertyPath alloc] initWithName:@"dict"
                                                                          key:@"1"];
        
        JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor *(void) {
            
            return [JFFPropertyExtractor new];
        };
        
        TestClassWithProperties *dataOwner = [TestClassWithProperties new];
        
        JFFAsyncOperation cachedLoader = [dataOwner asyncOperationForPropertyWithPath:propertyPath
                                                        propertyExtractorFactoryBlock:factory
                                                                       asyncOperation:nativeLoader.loader
                                                               didFinishLoadDataBlock:nil];
        
        __block NSError *resultError;
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            resultError = error;
        };
        
        JFFAsyncOperationHandler cancel = cachedLoader(nil, nil, doneCallback);
        
        GHAssertFalse(nativeLoader.finished  , @"OK");
        GHAssertFalse(nativeLoader.canceled  , @"OK");
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUndefined, @"OK");
        
        nativeLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertFalse(nativeLoader.finished  , @"OK");
        GHAssertTrue(nativeLoader.canceled  , @"OK");
        GHAssertTrue(nativeLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskUnsubscribe, @"OK");
        
        GHAssertTrue([resultError isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]], @"OK" );
        resultError = nil;
        
        cancel(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertNil(resultError, @"OK");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

-(void)testCachedAsyncOperationsOnceLoading
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *nativeLoader = [JFFAsyncOperationManager new];
        
        JFFPropertyPath* propertyPath_ = [[JFFPropertyPath alloc] initWithName:@"dict"
                                                                           key:@"1"];
        
        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ JFFPropertyExtractor new ];
        };
        
        TestClassWithProperties *dataOwner_ = [TestClassWithProperties new];
        
        JFFAsyncOperation cachedLoader_ = [ dataOwner_ asyncOperationForPropertyWithPath: propertyPath_
                                                           propertyExtractorFactoryBlock: factory_
                                                                          asyncOperation: nativeLoader.loader
                                                                  didFinishLoadDataBlock: nil ];

        GHAssertTrue( nativeLoader.loadingCount == 0, @"OK" );

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
                                                                           asyncOperation: nativeLoader.loader
                                                                   didFinishLoadDataBlock: nil ];
        __block BOOL finished3_ = NO;
        cachedLoader2_( nil, nil, ^( id result_, NSError* error_ )
        {
            finished3_ = result_ != nil;
        } );
        
        GHAssertFalse( nativeLoader.finished, @"OK" );
        GHAssertTrue( nativeLoader.loadingCount == 1, @"OK" );
        GHAssertFalse( finished1_, @"OK" );
        GHAssertFalse( finished2_, @"OK" );
        GHAssertFalse( finished3_, @"OK" );

        GHAssertTrue( dataOwner_.dict[@"1"] == nil, @"OK" );

        id result_ = [ NSNull null ];
        nativeLoader.loaderFinishBlock(result_, nil);

        GHAssertTrue( nativeLoader.finished, @"OK" );
        GHAssertTrue( finished1_, @"OK" );
        GHAssertTrue( finished2_, @"OK" );
        GHAssertTrue( finished3_, @"OK" );

        GHAssertTrue( dataOwner_.dict[@"1"] == result_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFAsyncOperationHandlerBlockHolder   instancesCount ], @"OK" );
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
        JFFAsyncOperationManager* nativeLoader_ = [ JFFAsyncOperationManager new ];

        JFFPropertyPath* propertyPath_ = [ [ JFFPropertyPath alloc ] initWithName: @"dict"
                                                                                key: @"1" ];

        JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
        {
            return [ JFFPropertyExtractor new ];
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

                [dataOwner_ addOnDeallocBlock:^() {
                    deallocated_ = YES;
                }];
                
                unsubscribeLoader_(nil, nil, nil);
            }

            nativeLoader_.loaderFinishBlock([NSNull null], nil);
        }
        GHAssertTrue(deallocated_, @"OK");
    }

    GHAssertTrue( 0 == [ JFFAsyncOperationHandlerBlockHolder   instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
