#import <Foundation/Foundation.h>

@class JFFDownloadItem;

@protocol JFFDownloadItemDelegate <NSObject>

@optional
- (void)didProgressChangeForDownloadItem:(JFFDownloadItem *)downloadItem;

- (void)didFailLoadingOfDownloadItem:(JFFDownloadItem *)downloadItem error:(NSError *)error;

- (void)didFinishLoadingOfDownloadItem:(JFFDownloadItem *)downloadItem;

- (void)didCancelLoadingOfDownloadItem:(JFFDownloadItem *)downloadItem;

@end
