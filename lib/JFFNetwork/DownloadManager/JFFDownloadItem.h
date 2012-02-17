#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFDownloadItemDelegate;

extern long long JFFUnknownFileLength;

@interface JFFDownloadItem : NSObject

@property ( nonatomic, retain, readonly ) NSURL* url;
@property ( nonatomic, retain, readonly ) NSString* localFilePath;

@property ( nonatomic, assign, readonly ) unsigned long long fileLength;
@property ( nonatomic, assign, readonly ) unsigned long long downloadedFileLength;
@property ( nonatomic, assign, readonly ) BOOL downloaded;
@property ( nonatomic, assign, readonly ) float progress;
@property ( nonatomic, assign, readonly ) BOOL activeDownload;
@property ( nonatomic, assign, readonly ) float downlodingSpeed;

//can return existing download item
+(id)downloadItemWithURL:( NSURL* )url_
           localFilePath:( NSString* )local_file_path_
                   error:( NSError** )error_;

+(BOOL)removeDownloadForURL:( NSURL* )url_
              localFilePath:( NSString* )local_file_path_
                      error:( NSError** )error_;

-(void)start;
-(void)stop;
-(void)removeDownload;

-(void)addDelegate:( id< JFFDownloadItemDelegate > )delegate_;
-(void)removeDelegate:( id< JFFDownloadItemDelegate > )delegate_;

-(JFFAsyncOperation)fileLoader;

@end
