#import <JFFJsonTools/Errors/JFFJsonToolsError.h>

@interface JFFParseJsonError : JFFJsonToolsError

@property (nonatomic) NSError *nativeError;
@property (nonatomic) NSData  *data;
@property (nonatomic) id<NSCopying> context;

@end
