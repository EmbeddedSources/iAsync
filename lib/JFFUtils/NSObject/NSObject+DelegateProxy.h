#import <Foundation/Foundation.h>

@interface NSObject (DelegateProxy)

- (void)setDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName;

@end
