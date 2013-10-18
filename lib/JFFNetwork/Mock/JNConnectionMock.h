#import <JFFNetwork/Mock/JNMock.h>
#import <Foundation/Foundation.h>

@interface JNConnectionMock : NSObject< JNMock >

- (instancetype)initWithConnectionClass:(Class )connectionClass
                                 action:(void (^)(void))action //JFFSimpleBlock
                    executeOriginalImpl:(BOOL)yesNo;

@property (nonatomic, readonly) BOOL isMockEnabled;

@end
