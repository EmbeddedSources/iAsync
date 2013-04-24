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

@interface JFFDownloadItem () <JFFTrafficCalculatorDelegate>

@property (nonatomic) NSURL* url;
@property (nonatomic) NSString* localFilePath;
@property (nonatomic) float downlodingSpeed;
@property (nonatomic) unsigned long long fileLength;
@property (nonatomic) unsigned long long downloadedFileLength;
@property (nonatomic) NSNull* downloadedFlag;
@property (nonatomic, copy) JFFCancelAsyncOperation stopBlock;

@end

@implementation JFFDownloadItem
{
    JFFTrafficCalculator *_trafficCalculator;
    FILE *_file;
    float _previousProgress;
    JFFMulticastDelegate< JFFDownloadItemDelegate > *_multicastDelegate;
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
        _multicastDelegate = (JFFMulticastDelegate< JFFDownloadItemDelegate >*)[ JFFMulticastDelegate new ];

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
   if ( !_trafficCalculator )
   {
      _trafficCalculator = [ [ JFFTrafficCalculator alloc ] initWithDelegate: self ];
   }
   return _trafficCalculator;
}

-(void)closeFile
{
    if ( _file )
    {
        fclose( _file );
        _file = 0;
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
    if (self.stopBlock)
        return;
    
    [self fileLoader](nil, nil, ^(id result, NSError *error){
        
        [error writeErrorWithJFFLogger];
    });
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
    [ _multicastDelegate addDelegate: delegate_ ];
}

-(void)removeDelegate:( id< JFFDownloadItemDelegate > )delegate_
{
    [ _multicastDelegate removeDelegate: delegate_ ];
}

#pragma mark JFFURLConnection callbacks

-(void)finalizeLoading
{
    self.stopBlock = nil;
    [ self closeFile ];
    [ _trafficCalculator stop ];
    _trafficCalculator = nil;
}

-(void)notifyFinishWithError:( NSError* )error
{
    if ( error )
        [ _multicastDelegate didFailLoadingOfDownloadItem: self error: error ];
    else
        [ _multicastDelegate didFinishLoadingOfDownloadItem: self ];
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

    [_multicastDelegate didCancelLoadingOfDownloadItem:self];

    if (cancelCallback)
        cancelCallback(canceled);
}

-(void)didReceiveData:( NSData* )data_
      progressHandler:( JFFAsyncOperationProgressHandler )progress_callback_
{
    if ( !_trafficCalculator )
        [ self.trafficCalculator startLoading ];

    if ( !_file )
        _file = [ JFFFileManager createFileForPath: self.localFilePath ];

    fwrite([ data_ bytes ], 1, [ data_ length ], _file );
    fflush(_file );
    
    [self.trafficCalculator bytesReceived:data_.length];
    
    self.downloadedFileLength += data_.length;
    
    if ((self.progress - _previousProgress) > 0.005f)
    {
        _previousProgress = self.progress;
        [ _multicastDelegate didProgressChangeForDownloadItem: self ];
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
    JFFAsyncOperation loader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                         JFFCancelAsyncOperationHandler cancelCallback,
                                                         JFFDidFinishAsyncOperationHandler doneCallback)
    {
        NSString *range_ = [[NSString alloc] initWithFormat:@"bytes=%qu-", self.downloadedFileLength];
        NSDictionary *headers_ = @{ @"Range" : range_ };
        
        JFFURLConnectionParams* params = [ JFFURLConnectionParams new ];
        params.url     = self.url;
        params.headers = headers_;
        JFFURLConnection *connection = [[JFFURLConnection alloc] initWithURLConnectionParams:params];
        
        progressCallback = [ progressCallback copy ];
        connection.didReceiveDataBlock = ^(NSData *data) {
            [self didReceiveData:data
                 progressHandler:progressCallback];
        };
        
        doneCallback = [doneCallback copy];
        connection.didFinishLoadingBlock = ^(NSError *error) {
            
            [self didFinishLoadedWithError:error];
            
            if (doneCallback)
                doneCallback(error?nil:[NSNull new], error);
        };
        
        connection.didReceiveResponseBlock = ^(id/*< JNUrlResponse >*/ response) {
            [self didReceiveResponse:response];
        };
        
        JFFCancelAsyncOperationBlockHolder *cancelCallbackBlockHolder = [ JFFCancelAsyncOperationBlockHolder new ];
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelCallbackWrapper = ^(BOOL canceled)
        {
            [self didCancelWithFlag:canceled cancelCallback:cancelCallback];
        };
        cancelCallbackBlockHolder.cancelBlock = cancelCallbackWrapper;
        
        [connection start];
        
        [_multicastDelegate didProgressChangeForDownloadItem:self];
        
        self.stopBlock = ^void(BOOL canceled)
        {
            if (canceled)
                [connection cancel];
            else
                assert(NO);// pass canceled as YES only
            
            cancelCallbackBlockHolder.onceCancelBlock(canceled);
        };
        return self.stopBlock;
    };
    
    loader = [self asyncOperationForPropertyWithName:@"downloadedFlag"
                                      asyncOperation:loader];
    
    JFFDidFinishAsyncOperationHandler didFinishOperation = ^void(id result, NSError *error) {
        [self notifyFinishWithError:error];
    };
    return asyncOperationWithFinishCallbackBlock(loader,
                                                 didFinishOperation);
}

#pragma mark JFFTrafficCalculatorDelegate

-(void)trafficCalculator:( JFFTrafficCalculator* )traffic_calculator_
  didChangeDownloadSpeed:( float )speed_
{
    self.downlodingSpeed = speed_;
    [ _multicastDelegate didProgressChangeForDownloadItem: self ];
}

@end
