#import <Foundation/Foundation.h>

@interface JFFDBInfo : NSObject

@property (atomic, readonly) NSDictionary *dbInfo;
@property (atomic) NSDictionary *currentDbInfo;

- (instancetype)initWithInfoPath:(NSString *)infoPath;
- (instancetype)initWithInfoDictionary:(NSDictionary *)infoDictionry;

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo;
+ (JFFDBInfo *)sharedDBInfo;

@end
