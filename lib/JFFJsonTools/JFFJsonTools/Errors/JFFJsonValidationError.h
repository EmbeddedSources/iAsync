#import <JFFJsonTools/Errors/JFFJsonToolsError.h>

@interface JFFJsonValidationError : JFFJsonToolsError

@property (nonatomic) id jsonObject;
@property (nonatomic) id jsonPattern;
@property (nonatomic) NSString *message;

@end
