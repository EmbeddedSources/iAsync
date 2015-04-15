#import <Foundation/Foundation.h>

@protocol JNMock <NSObject>

- (void)enableMock;
- (void)disableMock;

- (BOOL)isMockEnabled;

@end
