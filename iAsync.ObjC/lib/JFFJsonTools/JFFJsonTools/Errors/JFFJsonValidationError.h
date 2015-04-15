#import <JFFJsonTools/Errors/JFFJsonToolsError.h>

#import <Foundation/Foundation.h>

@interface JFFJsonValidationError : JFFJsonToolsError

@property (nonatomic) id jsonObject;
@property (nonatomic) id jsonPattern;
@property (nonatomic) NSString *message;

@end
