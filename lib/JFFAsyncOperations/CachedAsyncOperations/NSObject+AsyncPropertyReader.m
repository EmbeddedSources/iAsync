#import "NSObject+AsyncPropertyReader.h"

#import "JFFPropertyPath.h"
#import "JFFPropertyExtractor.h"
#import "JFFObjectRelatedPropertyData.h"
#import "JFFCallbacksBlocksHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "NSObject+PropertyExtractor.h"

#include <objc/runtime.h>
#include <assert.h>

@interface JFFCachePropertyExtractor : JFFPropertyExtractor
@end

@implementation JFFCachePropertyExtractor

-(id)property
{
    return nil;
}

-(void)setProperty:( id )propertyPath_
{
}

@end

@interface NSObject (PrivateAsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates;

@end

@interface NSDictionary (AsyncPropertyReader)
@end

@implementation NSDictionary (AsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates
{
    __block BOOL result_ = NO;

    [ self enumerateKeysAndObjectsUsingBlock: ^void( id key, id value_, BOOL* stop )
    {
        if ( [ value_ hasAsyncPropertyDelegates ] )
        {
            *stop = YES;
            result_ = YES;
        }
    } ];

    return result_;
}

@end

@interface JFFObjectRelatedPropertyData (AsyncPropertyReader)
@end

@implementation JFFObjectRelatedPropertyData (AsyncPropertyReader)

-(BOOL)hasAsyncPropertyDelegates
{
    return [ self.delegates count ] > 0;
}

@end

static void clearDelegates( NSArray* delegates_ )
{
    [ delegates_ each: ^void( id obj_ )
    {
        JFFCallbacksBlocksHolder* callback_ = obj_;
        callback_.didLoadDataBlock = nil;
        callback_.onCancelBlock = nil;
        callback_.onProgressBlock = nil;
    } ];
}

static void clearDataForPropertyExtractor( JFFPropertyExtractor* property_extractor_ )
{
    clearDelegates( property_extractor_.delegates );
    property_extractor_.delegates = nil;
    property_extractor_.cancelBlock = nil;
    property_extractor_.didFinishBlock = nil;
    property_extractor_.asyncLoader = nil;

    [ property_extractor_ clearData ];
}

static JFFCancelAsyncOperation cancelBlock( JFFPropertyExtractor* property_extractor_
                                           , JFFCallbacksBlocksHolder* callbacks_ )
{
    return ^void( BOOL cancelOperation_ )
    {
        JFFCancelAsyncOperation cancel_ = property_extractor_.cancelBlock;
        if ( !cancel_ )
            return;

        cancel_ = [ cancel_ copy ];

        if ( cancelOperation_ )
        {
            cancel_( YES );
            clearDataForPropertyExtractor( property_extractor_ );
        }
        else
        {
            [ property_extractor_.delegates removeObject: callbacks_ ];
            callbacks_.didLoadDataBlock = nil;
            callbacks_.onProgressBlock = nil;

            if ( callbacks_.onCancelBlock )
                callbacks_.onCancelBlock( NO );

            callbacks_.onCancelBlock = nil;
        }
    };
}

static JFFDidFinishAsyncOperationHandler doneCallbackBlock( JFFPropertyExtractor* propertyExtractor_ )
{
    return ^void( id result_, NSError* error_ )
    {
        if ( !result_ && !error_ )
        {
            NSLog( @"Assert propertyPath object: %@ propertyPath: %@"
                  , propertyExtractor_.object
                  , propertyExtractor_.propertyPath );
            assert( 0 );//@"should be result or error"
        }

        NSArray* copyDelegates_ = [ propertyExtractor_.delegates map: ^id( id obj_ )
        {
            JFFCallbacksBlocksHolder* callback_ = obj_;
            return [ [ JFFCallbacksBlocksHolder alloc ] initWithOnProgressBlock: callback_.onProgressBlock
                                                                  onCancelBlock: callback_.onCancelBlock
                                                               didLoadDataBlock: callback_.didLoadDataBlock ];
        } ];

        JFFDidFinishAsyncOperationHandler finish_block_ = [ propertyExtractor_.didFinishBlock copy ];

        propertyExtractor_.property = result_;

        if ( finish_block_ )
        {
            finish_block_( result_, error_ );
            result_ = propertyExtractor_.property;
        }

        clearDataForPropertyExtractor( propertyExtractor_ );

        [ copyDelegates_ each: ^void( id obj_ )
        {
            JFFCallbacksBlocksHolder* callback_ = obj_;
            if ( callback_.didLoadDataBlock )
                callback_.didLoadDataBlock( result_, result_ ? nil : error_ );
        } ];

        clearDelegates( copyDelegates_ );
    };
}

static JFFCancelAsyncOperation performNativeLoader( JFFPropertyExtractor* propertyExtractor_
                                                   , JFFCallbacksBlocksHolder* callbacks_ )
{
    JFFAsyncOperationProgressHandler progressCallback_ = ^void( id progress_info_ )
    {
        [ propertyExtractor_.delegates each: ^void( id obj_ )
        {
            JFFCallbacksBlocksHolder* obj_callback_ = obj_;
            if ( obj_callback_.onProgressBlock )
                obj_callback_.onProgressBlock( progress_info_ );
        } ];
    };

    JFFDidFinishAsyncOperationHandler doneCallback_ = doneCallbackBlock( propertyExtractor_ );

    JFFCancelAsyncOperationHandler cancelCallback_ = ^void( BOOL canceled_ )
    {
        JFFCancelAsyncOperationHandler cancelCallback_ = callbacks_.onCancelBlock;
        clearDataForPropertyExtractor( propertyExtractor_ );

        if ( cancelCallback_ )
            cancelCallback_( canceled_ );
    };

    propertyExtractor_.cancelBlock = propertyExtractor_.asyncLoader( progressCallback_
                                                                    , cancelCallback_
                                                                    , doneCallback_ );

    if ( nil == propertyExtractor_.cancelBlock )
    {
        return JFFStubCancelAsyncOperationBlock;
    }

    return cancelBlock( propertyExtractor_, callbacks_ );
}

@implementation NSObject (AsyncPropertyReader)

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_
{
    return [ self.propertyDataByPropertyName[ name_ ] hasAsyncPropertyDelegates ];
}

-(JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                               propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                              asyncOperation:( JFFAsyncOperation )asyncOperation_
                                      didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    NSParameterAssert( asyncOperation_ );

    asyncOperation_     = [ asyncOperation_     copy ];
    didFinishOperation_ = [ didFinishOperation_ copy ];
    factory_            = [ factory_            copy ];

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFPropertyExtractor* propertyExtractor_ = factory_();
        propertyExtractor_.object       = self;
        propertyExtractor_.propertyPath = propertyPath_;

        id result_ = propertyExtractor_.property;
        if ( result_ )
        {
            if ( doneCallback_ )
                doneCallback_( result_, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        propertyExtractor_.asyncLoader    = asyncOperation_;
        propertyExtractor_.didFinishBlock = didFinishOperation_;

        JFFCallbacksBlocksHolder* callbacks_ =
            [ [ JFFCallbacksBlocksHolder alloc ] initWithOnProgressBlock: progressCallback_
                                                           onCancelBlock: cancelCallback_
                                                        didLoadDataBlock: doneCallback_ ];

        if ( nil == propertyExtractor_.delegates )
        {
            propertyExtractor_.delegates = [ @[ callbacks_ ] mutableCopy ];
        }

        if ( propertyExtractor_.cancelBlock != nil )
        {
            [ propertyExtractor_.delegates addObject: callbacks_ ];
            return cancelBlock( propertyExtractor_, callbacks_ );
        }

        return performNativeLoader( propertyExtractor_, callbacks_ );
    };
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    NSAssert( propertyPath_.name && propertyPath_.key, @"propertyName argument should not be nil" );
    return [ self privateAsyncOperationForPropertyWithPath: propertyPath_
                             propertyExtractorFactoryBlock: factory_
                                            asyncOperation: asyncOperation_
                                    didFinishLoadDataBlock: didFinishOperation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
{
    return [ self asyncOperationForPropertyWithPath: propertyPath_
                      propertyExtractorFactoryBlock: factory_
                                     asyncOperation: asyncOperation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                              asyncOperation:( JFFAsyncOperation )asyncOperation_
                                      didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
    {
        return [ JFFPropertyExtractor new ];
    };

    return [ self privateAsyncOperationForPropertyWithPath: propertyPath_
                             propertyExtractorFactoryBlock: factory_
                                            asyncOperation: asyncOperation_
                                    didFinishLoadDataBlock: didFinishOperation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
{
    return [ self asyncOperationForPropertyWithName: property_name_
                                     asyncOperation: asyncOperation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    NSParameterAssert( propertyName_ );
    JFFPropertyPath* propertyPath_ = [ [ JFFPropertyPath alloc ] initWithName: propertyName_ key: nil ];

    return [ self privateAsyncOperationForPropertyWithPath: propertyPath_
                                            asyncOperation: asyncOperation_
                                    didFinishLoadDataBlock: didFinishOperation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
{
    return [ self asyncOperationForPropertyWithPath: propertyPath_
                                     asyncOperation: asyncOperation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    NSAssert( propertyPath_.name && propertyPath_.key, @"propertyName argument should not be nil" );
    return [ self privateAsyncOperationForPropertyWithPath: propertyPath_
                                            asyncOperation: asyncOperation_
                                    didFinishLoadDataBlock: didFinishOperation_ ];
}

-(JFFAsyncOperation)asyncOperationMergeLoaders:( JFFAsyncOperation )asyncOperation_
                                  withArgument:( id< NSCopying, NSObject > )argument_
{
    static NSString* const name_ = @".__JFF_MERGE_LOADERS_BY_ARGUMENTS__.";
    JFFPropertyPath* propertyPath_ = [ [ JFFPropertyPath alloc ] initWithName: name_
                                                                          key: argument_ ];
    JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
    {
        return [ JFFCachePropertyExtractor new ];
    };

    return [ self asyncOperationForPropertyWithPath: propertyPath_
                      propertyExtractorFactoryBlock: factory_
                                     asyncOperation: asyncOperation_
                             didFinishLoadDataBlock: nil ];
}

@end
