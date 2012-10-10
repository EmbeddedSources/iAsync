#import <JFFJsonTools/Errors/JFFJsonToolsError.h>

@interface JFFParseJsonError : JFFJsonToolsError

@property (nonatomic) NSError *nativeError;
@property (nonatomic) NSData  *data;

@end
