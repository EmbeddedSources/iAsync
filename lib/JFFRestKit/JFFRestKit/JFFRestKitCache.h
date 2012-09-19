#import <Foundation/Foundation.h>

@protocol JFFRestKitCache <NSObject>

@required
- (void)setData:(NSData *)data forKey:(NSString *)key;
- (NSData*)dataForKey:(NSString *)key lastUpdateDate:(NSDate **)date;

@end

