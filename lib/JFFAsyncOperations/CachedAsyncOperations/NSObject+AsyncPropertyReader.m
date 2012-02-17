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

-(void)setProperty:( id )property_path_
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
   for ( NSObject* value_ in [ self allValues ] )
   {
      if ( [ value_ hasAsyncPropertyDelegates ] )
         return YES;
   }

   return NO;
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
   return ^void( BOOL cancel_operation_ )
   {
      JFFCancelAsyncOperation cancel_ = property_extractor_.cancelBlock;
      if ( !cancel_ )
         return;

      cancel_ = [ cancel_ copy ];

      if ( cancel_operation_ )
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

static JFFDidFinishAsyncOperationHandler doneCallbackBlock( JFFPropertyExtractor* property_extractor_ )
{
   return ^void( id result_, NSError* error_ )
   {
      if ( !result_ && !error_ )
      {
         NSLog( @"Assert propertyPath object: %@ propertyPath: %@"
               , property_extractor_.object
               , property_extractor_.propertyPath );
         assert( 0 );//@"should be result or error"
      }

      NSArray* copy_delegates_ = [ property_extractor_.delegates map: ^id( id obj_ )
      {
         JFFCallbacksBlocksHolder* callback_ = obj_;
         return [ [ JFFCallbacksBlocksHolder alloc ] initWithOnProgressBlock: callback_.onProgressBlock
                                                               onCancelBlock: callback_.onCancelBlock
                                                            didLoadDataBlock: callback_.didLoadDataBlock ];
      } ];

      JFFDidFinishAsyncOperationHandler finish_block_ = [ property_extractor_.didFinishBlock copy ];

      property_extractor_.property = result_;

      if ( finish_block_ )
      {
         finish_block_( result_, error_ );
         result_ = property_extractor_.property;
      }

      clearDataForPropertyExtractor( property_extractor_ );

      [ copy_delegates_ each: ^void( id obj_ )
      {
         JFFCallbacksBlocksHolder* callback_ = obj_;
         if ( callback_.didLoadDataBlock )
            callback_.didLoadDataBlock( result_, result_ ? nil : error_ );
      } ];

      clearDelegates( copy_delegates_ );
   };
}

static JFFCancelAsyncOperation performNativeLoader( JFFPropertyExtractor* property_extractor_
                                                   , JFFCallbacksBlocksHolder* callbacks_ )
{
   JFFAsyncOperationProgressHandler progress_callback_ = ^void( id progress_info_ )
   {
      [ property_extractor_.delegates each: ^void( id obj_ )
      {
         JFFCallbacksBlocksHolder* obj_callback_ = obj_;
         if ( obj_callback_.onProgressBlock )
            obj_callback_.onProgressBlock( progress_info_ );
      } ];
   };

   JFFDidFinishAsyncOperationHandler done_callback_ = doneCallbackBlock( property_extractor_ );

   JFFCancelAsyncOperationHandler cancel_callback_ = ^void( BOOL canceled_ )
   {
      JFFCancelAsyncOperationHandler cancel_callback_ = callbacks_.onCancelBlock;
      clearDataForPropertyExtractor( property_extractor_ );

      if ( cancel_callback_ )
          cancel_callback_( canceled_ );
   };

   property_extractor_.cancelBlock = property_extractor_.asyncLoader( progress_callback_
                                                                     , cancel_callback_
                                                                     , done_callback_ );

   if ( nil == property_extractor_.cancelBlock )
   {
      return JFFEmptyCancelAsyncOperationBlock;
   }

   return cancelBlock( property_extractor_, callbacks_ );
}

@implementation NSObject (AsyncPropertyReader)

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_
{
   return [ [ self.propertyDataByPropertyName objectForKey: name_ ] hasAsyncPropertyDelegates ];
}

-(JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                               propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                              asyncOperation:( JFFAsyncOperation )asyncOperation_
                                      didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_
{
    NSParameterAssert( asyncOperation_ );

    asyncOperation_     = [ asyncOperation_     copy ];
    didFinishOperation_ = [ didFinishOperation_ copy ];
    factory_            = [ factory_ copy ];

    //JTODO fix leak if this blocks owns self
    __unsafe_unretained id self_ = self;

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                    , JFFCancelAsyncOperationHandler cancel_callback_
                                    , JFFDidFinishAsyncOperationHandler done_callback_ )
    {
        JFFPropertyExtractor* property_extractor_ = factory_();
        property_extractor_.object       = self_;
        property_extractor_.propertyPath = property_path_;

        id result_ = property_extractor_.property;
        if ( result_ )
        {
            if ( done_callback_ )
                done_callback_( result_, nil );
            return JFFEmptyCancelAsyncOperationBlock;
        }

        property_extractor_.asyncLoader    = asyncOperation_;
        property_extractor_.didFinishBlock = didFinishOperation_;

        JFFCallbacksBlocksHolder* callbacks_ =
            [ [ JFFCallbacksBlocksHolder alloc ] initWithOnProgressBlock: progress_callback_
                                                           onCancelBlock: cancel_callback_
                                                        didLoadDataBlock: done_callback_ ];

        if ( nil == property_extractor_.delegates )
        {
            property_extractor_.delegates = [ NSMutableArray arrayWithObject: callbacks_ ];
        }

        if ( property_extractor_.cancelBlock != nil )
        {
            [ property_extractor_.delegates addObject: callbacks_ ];
            return cancelBlock( property_extractor_, callbacks_ );
        }

        return performNativeLoader( property_extractor_, callbacks_ );
    };
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
    NSAssert( property_path_.name && property_path_.key, @"propertyName argument should not be nil" );
    return [ self privateAsyncOperationForPropertyWithPath: property_path_
                             propertyExtractorFactoryBlock: factory_
                                            asyncOperation: async_operation_
                                    didFinishLoadDataBlock: did_finish_operation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
{
    return [ self asyncOperationForPropertyWithPath: property_path_
                      propertyExtractorFactoryBlock: factory_
                                     asyncOperation: async_operation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                              asyncOperation:( JFFAsyncOperation )async_operation_
                                      didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
    JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
    {
        return [ JFFPropertyExtractor new ];
    };

    return [ self privateAsyncOperationForPropertyWithPath: property_path_
                             propertyExtractorFactoryBlock: factory_
                                            asyncOperation: async_operation_
                                    didFinishLoadDataBlock: did_finish_operation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )property_name_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
{
    return [ self asyncOperationForPropertyWithName: property_name_
                                     asyncOperation: async_operation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
    NSParameterAssert( propertyName_ );
    JFFPropertyPath* property_path_ = [ [ JFFPropertyPath alloc ] initWithName: propertyName_ key: nil ];

    return [ self privateAsyncOperationForPropertyWithPath: property_path_
                                            asyncOperation: async_operation_
                                    didFinishLoadDataBlock: did_finish_operation_ ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
{
    return [ self asyncOperationForPropertyWithPath: property_path_
                                     asyncOperation: async_operation_
                             didFinishLoadDataBlock: nil ];
}

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )property_path_
                                       asyncOperation:( JFFAsyncOperation )async_operation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_finish_operation_
{
    NSAssert( property_path_.name && property_path_.key, @"propertyName argument should not be nil" );
    return [ self privateAsyncOperationForPropertyWithPath: property_path_
                                            asyncOperation: async_operation_
                                    didFinishLoadDataBlock: did_finish_operation_ ];
}

-(JFFAsyncOperation)asyncOperationMergeLoaders:( JFFAsyncOperation )asyncOperation_
                                  withArgument:( id< NSCopying, NSObject > )argument_
{
    JFFPropertyPath* property_path_ = [ [ JFFPropertyPath alloc ] initWithName: @".__JFF_MERGE_LOADERS_BY_ARGUMENTS__."
                                                                           key: argument_ ];
    JFFPropertyExtractorFactoryBlock factory_ = ^JFFPropertyExtractor*( void )
    {
        return [ JFFCachePropertyExtractor new ];
    };

    return [ self asyncOperationForPropertyWithPath: property_path_
                      propertyExtractorFactoryBlock: factory_
                                     asyncOperation: asyncOperation_
                             didFinishLoadDataBlock: nil ];
}

@end
