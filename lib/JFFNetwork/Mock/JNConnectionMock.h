#import <JFFNetwork/Mock/JNMock.h>
#import <Foundation/Foundation.h>

@interface JNConnectionMock : NSObject< JNMock >

@property (nonatomic, readonly) BOOL isMockEnabled;

- (instancetype)initWithConnectionClass:(Class )connectionClass
                                 action:(void (^)(void))action //JFFSimpleBlock
                    executeOriginalImpl:(BOOL)yesNo;

@end
