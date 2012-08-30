#import "JFFContextLoaders.h"

#import "JFFActiveLoaderData.h"
#import "JFFPedingLoaderData.h"

@interface JFFContextLoaders ()

// JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSMutableArray* activeLoadersData;
@property ( nonatomic, retain ) NSMutableArray* pendingLoadersData;

@end

@implementation JFFContextLoaders

-(void)dealloc
{
    [ self->_activeLoadersData release ];
    [ self->_pendingLoadersData release ];
    [ self->_name release ];

    [ super dealloc ];
}

-(NSMutableArray*)activeLoadersData
{
    if ( !self->_activeLoadersData )
    {
        self->_activeLoadersData = [ NSMutableArray new ];
    }
    return self->_activeLoadersData;
}

-(NSMutableArray*)pendingLoadersData
{
    if ( !self->_pendingLoadersData )
    {
        self->_pendingLoadersData = [ NSMutableArray new ];
    }
    return self->_pendingLoadersData;
}

@end

@implementation JFFContextLoaders ( ActiveLoaders )

-(NSUInteger)activeLoadersNumber
{
    return [ self->_activeLoadersData count ];
}

-(void)addActiveNativeLoader:( JFFAsyncOperation )native_loader_
               wrappedCancel:( JFFCancelAsyncOperation )cancel_
{
    JFFActiveLoaderData* data_ = [ JFFActiveLoaderData new ];
    data_.nativeLoader  = native_loader_;
    data_.wrappedCancel = cancel_;

    [ self.activeLoadersData addObject: data_ ];

    [ data_ release ];
}

-(JFFActiveLoaderData*)activeLoaderDataForNativeLoader:( JFFAsyncOperation )native_loader_
{
    return [ self.activeLoadersData firstMatch: ^BOOL( id object_ )
    {
        JFFActiveLoaderData* loader_data_ = object_;
        return loader_data_.nativeLoader == native_loader_;
    } ];
}

-(void)cancelActiveNativeLoader:( JFFAsyncOperation )native_loader_ cancel:( BOOL )canceled_
{
    JFFActiveLoaderData* data_ = [ self activeLoaderDataForNativeLoader: native_loader_ ];

    if ( data_ )
        data_.wrappedCancel( canceled_ );
}

-(BOOL)removeActiveNativeLoader:( JFFAsyncOperation )native_loader_
{
    JFFActiveLoaderData* data_ = [ self activeLoaderDataForNativeLoader: native_loader_ ];

    if ( data_ )
    {
        [ self.activeLoadersData removeObject: data_ ];
        return YES;
    }

    return NO;
}

@end

@implementation JFFContextLoaders ( PendingLoaders )

-(NSUInteger)pendingLoadersNumber
{
    return [ self.pendingLoadersData count ];
}

-(JFFPedingLoaderData*)popPendingLoaderData
{
    JFFPedingLoaderData* data_ = [ self.pendingLoadersData[ 0 ] retain ];
    [ self.pendingLoadersData removeObjectAtIndex: 0 ];
    if ( [ self.pendingLoadersData count ] == 0 )
    {
        self.pendingLoadersData = nil;
    }
    return [ data_ autorelease ];
}

-(void)addPendingNativeLoader:( JFFAsyncOperation )native_loader_
             progressCallback:( JFFAsyncOperationProgressHandler )progress_callback_
               cancelCallback:( JFFCancelAsyncOperationHandler )cancel_callback_
                 doneCallback:( JFFDidFinishAsyncOperationHandler )done_callback_
{
    JFFPedingLoaderData* data_ = [ JFFPedingLoaderData new ];
    data_.nativeLoader     = native_loader_;
    data_.progressCallback = progress_callback_;
    data_.cancelCallback   = cancel_callback_;
    data_.doneCallback     = done_callback_;

    [ self.pendingLoadersData addObject: data_ ];

    [ data_ release ];
}

-(JFFPedingLoaderData*)pendingLoaderDataForNativeLoader:( JFFAsyncOperation )native_loader_
{
    return [ self.pendingLoadersData firstMatch: ^BOOL( id object_ )
    {
        JFFPedingLoaderData* loaderData_ = object_;
        return loaderData_.nativeLoader == native_loader_;
    } ];
}

-(BOOL)containsPendingNativeLoader:( JFFAsyncOperation )native_loader_
{
    return [ self pendingLoaderDataForNativeLoader: native_loader_ ] != nil;
}

-(void)removePendingNativeLoader:( JFFAsyncOperation )native_loader_
{
    JFFPedingLoaderData* data_ = [ self pendingLoaderDataForNativeLoader: native_loader_ ];

    [ self.pendingLoadersData removeObject: data_ ];
}

-(void)unsubscribePendingNativeLoader:( JFFAsyncOperation )native_loader_
{
    JFFPedingLoaderData* data_ = [ self pendingLoaderDataForNativeLoader: native_loader_ ];
    NSAssert( data_, @"pending loader data should exist" );

    data_.progressCallback = nil;
    data_.cancelCallback   = nil;
    data_.doneCallback     = nil;
}

@end
