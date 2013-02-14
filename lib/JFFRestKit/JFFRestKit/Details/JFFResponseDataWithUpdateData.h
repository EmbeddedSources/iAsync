#import <Foundation/Foundation.h>

@interface JFFResponseDataWithUpdateData : NSObject <NSCopying>

@property (nonatomic) NSData *data;
@property (nonatomic) NSDate *updateDate;

@end
