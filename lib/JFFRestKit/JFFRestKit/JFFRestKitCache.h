#import <Foundation/Foundation.h>

@protocol JFFRestKitCache <NSObject>

@required
-(void)setData:( NSData* )data_ forKey:( NSString* )key_;
-(NSData*)dataForKey:( NSString* )data_ lastUpdateDate:( NSDate** )date_;

@end

