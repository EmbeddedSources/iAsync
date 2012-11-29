#import "JFFDownloadItem.h"

#import "JFFFileManager.h"
#import "JFFURLConnection.h"
#import "NSMutableSet+DownloadManager.h"
#import "JFFDownloadItemDelegate.h"
#import "JFFURLResponse.h"
#import "JFFURLConnectionParams.h"

#import "JFFTrafficCalculator.h"
#import "JFFTrafficCalculatorDelegate.h"
#import "NSMutableDictionary+DownloadingFileInfo.h"

#import <JFFAsyncOperations/CachedAsyncOperations/NSObject+AsyncPropertyReader.h>
#import <JFFAsyncOperations/JFFAsyncOperationHelpers.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

static JFFMutableAssignArray* downloadItems_ = nil;

long long JFFUnknownFileLength = NSURLResponseUnknownLength;

//TODO move library to separate repository
@interface JFFDownloadItem () <JFFTrafficCalculatorDelegate>

@property ( nonatomic ) NSURL* url;
@property ( nonatomic ) NSString* localFilePath;
@property ( nonatomic ) float downlodingSpeed;
@property ( nonatomic ) unsigned long long fileLength;
@property ( nonatomic ) unsigned long long downloadedFileLength;
@property ( nonatomic ) NSNull* downloadedFlag;
@property ( nonatomic, copy   ) JFFCancelAsyncOperation stopBlock;

@end

@implementation JFFDownloadItem
{
    JFFTrafficCalculator* _trafficCalculator;
    FILE* _file;
    float _previousProgress;
    JFFMulticastDelegate< JFFDownloadItemDelegate >* _multicastDelegate;
}

@dynamic downloadedFlag;
@dynamic downloaded;
@dynamic activeDownload;

-(void)dealloc
{
    [ self closeFile ];
}

-(unsigned long long)fileSizeForURL:( NSURL* )url_
{
    NSDictionary* dict_ = [ [ NSFileManager defaultManager ] attributesOfItemAtPath: self.localFilePath error: nil ];
    return [ dict_ fileSize ];
}

-(id)initWithURL:( NSURL* )url_
   localFilePath:( NSString* )local_file_path_
{
    self = [ super init ];

    if ( self )
    {
        self.url = url_;
        self.localFilePath = local_file_path_;
        self.downloadedFileLength = [ self fileSizeForURL: url_ ];
        self->_multicastDelegate = (JFFMulticastDelegate< JFFDownloadItemDelegate >*)[ JFFMulticastDelegate new ];

        if ( self.downloaded )
        {
            self.fileLength = self.downloadedFileLength;
        }
        else
        {
            self.fileLength = [ NSMutableDictionary fileLengthForDestinationURL: url_ ];
        }
    }

    return self;
}

-(JFFTrafficCalculator*)trafficCalculator
{
   if ( !self->_trafficCalculator )
   {
      self->_trafficCalculator = [ [ JFFTrafficCalculator alloc ] initWithDelegate: self ];
   }
   return self->_trafficCalculator;
}

-(void)closeFile
{
    if ( self->_file )
    {
        fclose( self->_file );
        self->_file = 0;
    }
}

-(NSNull*)downloadedFlag
{
    BOOL downloded_ = [ NSMutableSet containsDownloadedFileWithPath: self.localFilePath ];
    return downloded_ ? [ NSNull null ] : nil;
}

-(void)setDownloadedFlag:( NSNull* )downloaded_flag_
{
    if ( downloaded_flag_ )
        [ NSMutableSet addDownloadedFileWithPath: self.localFilePath ];
}

-(float)progress
{
   return ( self.fileLength == NSURLResponseUnknownLength ) ? 0.f : (float) self.downloadedFileLength / self.fileLength;
}

+ (BOOL)checkNotAlreadyUsedLocalPath:(NSString *)localFilePath
                                 url:(NSURL *)url
                               error:(NSError **)outError
{
    BOOL result = ![downloadItems_ any:^BOOL(id object) {
        JFFDownloadItem *item_ = object;
        return ![item_.url isEqual:url]
            && [ item_.localFilePath isEqualToString:localFilePath];
    }];
    
    if (!result && outError) {
        
        //TODO use NSLocalizedString here
        static NSString *const errorDescription = @"Invalid arguments. This \"local path\" used for another url";
        *outError = [JFFError newErrorWithDescription:errorDescription];
    }
    
    return result;
}

+(id)downloadItemWithURL:( NSURL* )url_
           localFilePath:( NSString* )local_file_path_
                   error:( NSError** )outError
{
    if ( ![ self checkNotAlreadyUsedLocalPath: local_file_path_ url: url_ error: outError ] )
        return nil;
    
    id result = [ downloadItems_ firstMatch: ^BOOL(id object) {
        JFFDownloadItem* item_ = object;
        return [ item_.url isEqual: url_ ]
            && [ item_.localFilePath isEqualToString: local_file_path_ ];
    } ];
    
    if ( !result )
    {
        result = [ [ self alloc ] initWithURL: url_ localFilePath: local_file_path_ ];
        if ( !downloadItems_ )
        {
            downloadItems_ = [ JFFMutableAssignArray new ];
        }
        [ downloadItems_ addObject: result ];
    }

    return result;
}

-(BOOL)downloaded
{
    return self.downloadedFlag != nil;
}

-(BOOL)activeDownload
{
    return self.stopBlock != nil;
}

-(void)start
{
    if ( !self.stopBlock )
        [ self fileLoader ]( nil, nil, nil );
}

-(void)stop
{
    if ( self.stopBlock )
    {
        JFFCancelAsyncOperation stop_block_ = [ self.stopBlock copy ];
        self.stopBlock = nil;
        stop_block_( YES );
    }
}

-(void)removeDownload
{
    [ self stop ];
    [ NSMutableSet removeDownloadedFileWithPath: self.localFilePath ];
}

+(BOOL)removeDownloadForURL:( NSURL* )url_
              localFilePath:( NSString* )local_file_path_
                      error:( NSError** )outError
{
    @autoreleasepool
    {
        JFFDownloadItem* item_ = [ self downloadItemWithURL: url_ localFilePath: local_file_path_ error: outError ];
        [ item_ removeDownload ];
        return item_ != nil;
    }
   
    return NO;
}

-(void)addDelegate:( id< JFFDownloadItemDelegate > )delegate_
{
    [ self->_multicastDelegate addDelegate: delegate_ ];
}

-(void)removeDelegate:( id< JFFDownloadItemDelegate > )delegate_
{
    [ self->_multicastDelegate removeDelegate: delegate_ ];
}

#pragma mark JFFURLConnection callbacks

-(void)finalizeLoading
{
    self.stopBlock = nil;
    [ self closeFile ];
    [ self->_trafficCalculator stop ];
    self->_trafficCalculator = nil;
}

-(void)notifyFinishWithError:( NSError* )error
{
    if ( error )
        [ self->_multicastDelegate didFailLoadingOfDownloadItem: self error: error ];
    else
        [ self->_multicastDelegate didFinishLoadingOfDownloadItem: self ];
}

-(void)didFinishLoadedWithError:( NSError* )error_
{
    id downloaded_flag_ = error_ ? nil : [ NSNull null ];
    self.downloadedFlag = downloaded_flag_;

    [ self finalizeLoading ];
}

- (void)didCancelWithFlag:( BOOL )canceled
           cancelCallback:( JFFCancelAsyncOperationHandler )cancelCallback
{
    NSParameterAssert(canceled);
    [self finalizeLoading];

    [self->_multicastDelegate didCancelLoadingOfDownloadItem:self];

    if (cancelCallback)
        cancelCallback(canceled);
}

-(void)didReceiveData:( NSData* )data_
      progressHandler:( JFFAsyncOperationProgressHandler )progress_callback_
{
    if ( !_trafficCalculator )
        [ self.trafficCalculator startLoading ];

    if ( !_file )
        self->_file = [ JFFFileManager createFileForPath: self.localFilePath ];

    fwrite( [ data_ bytes ], 1, [ data_ length ], _file );
    fflush( self->_file );

    [ self.trafficCalculator bytesReceived: data_.length ];

    self.downloadedFileLength += data_.length;

    if ( ( self.progress - _previousProgress ) > 0.005f )
    {
        self->_previousProgress = self.progress;
        [ self->_multicastDelegate didProgressChangeForDownloadItem: self ];
    }

    if ( progress_callback_ )
        progress_callback_( self );
}

-(void)didReceiveResponse:( JFFURLResponse* )response_
{
    self.fileLength = self.downloadedFileLength + response_.expectedContentLength;
}

-(JFFAsyncOperation)fileLoader
{
    JFFAsyncOperation loader_ = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progress_callback_,
                                                         JFFCancelAsyncOperationHandler cancel_callback_,
                                                         JFFDidFinishAsyncOperationHandler done_callback_)
    {
        NSString* range_ = [ [ NSString alloc ] initWithFormat: @"bytes=%qu-", self.downloadedFileLength ];
        NSDictionary* headers_ = @{ @"Range" : range_ };

        JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
        params_.url     = self.url;
        params_.headers = headers_;
        JFFURLConnection* connection_ = [ [ JFFURLConnection alloc ] initWithURLConnectionParams: params_ ];

        progress_callback_ = [ progress_callback_ copy ];
        connection_.didReceiveDataBlock = ^( NSData* data_ )
        {
            [ self didReceiveData: data_ 
                  progressHandler: progress_callback_ ];
        };

        done_callback_ = [ done_callback_ copy ];
        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            [ self didFinishLoadedWithError: error_ ];

            if ( done_callback_ )
                done_callback_( error_ ? nil : [ NSNull null ], error_ );
        };

        connection_.didReceiveResponseBlock = ^( id/*< JNUrlResponse >*/ response_ )
        {
            [ self didReceiveResponse: response_ ];
        };

        JFFCancelAsyncOperationBlockHolder* cancelCallbackBlockHolder_ = [ JFFCancelAsyncOperationBlockHolder new ];
        cancel_callback_ = [ cancel_callback_ copy ];
        JFFCancelAsyncOperationHandler cancelCallbackWrapper_ = ^( BOOL canceled_ )
        {
            [ self didCancelWithFlag: canceled_ cancelCallback: cancel_callback_ ];
        };
        cancelCallbackBlockHolder_.cancelBlock = cancelCallbackWrapper_;

        [ connection_ start ];

        [ self->_multicastDelegate didProgressChangeForDownloadItem: self ];

        self.stopBlock = ^void( BOOL canceled_ )
        {
            if ( canceled_ )
                [ connection_ cancel ];
            else
                assert( NO );// pass canceled_ as YES only

            cancelCallbackBlockHolder_.onceCancelBlock( canceled_ );
        };
        return self.stopBlock;
    };

    loader_ = [ self asyncOperationForPropertyWithName: @"downloadedFlag"
                                        asyncOperation: loader_ ];

    JFFDidFinishAsyncOperationHandler did_finish_operation_ = ^void( id result_, NSError* error ) {
        [ self notifyFinishWithError:error];
    };
    return asyncOperationWithFinishCallbackBlock( loader_
                                                 , did_finish_operation_ );
}

#pragma mark JFFTrafficCalculatorDelegate

-(void)trafficCalculator:( JFFTrafficCalculator* )traffic_calculator_
  didChangeDownloadSpeed:( float )speed_
{
    self.downlodingSpeed = speed_;
    [ self->_multicastDelegate didProgressChangeForDownloadItem: self ];
}

@end
