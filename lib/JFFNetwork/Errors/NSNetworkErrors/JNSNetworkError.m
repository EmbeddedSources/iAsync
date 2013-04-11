#import "JNSNetworkError.h"

#import "JNSNoInternetNetworkError.h"

@implementation JNSNetworkError
{
    id<NSCopying> _context;
    NSError *_nativeError;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithContext:(id<NSCopying>)context
          nativeError:(NSError *)nativeError
{
    self = [self initWithDescription:NSLocalizedString(@"JNETWORK_GENERIC_ERROR", nil)];
    
    if (self) {
        _context     = context;
        _nativeError = nativeError;
    }
    
    return self;
}

+ (BOOL)isMineNSNetworkError:(NSError *)error
{
    return NO;
}

+ (id)newJNSNetworkErrorWithContext:(id<NSCopying>)context
                        nativeError:(NSError *)nativeError
{
    Class class = Nil;
    
    //select class for error
    {
        NSArray *errorClasses =
        @[
          [JNSNoInternetNetworkError class],
          ];
        
        class = [errorClasses firstMatch:^BOOL(id object) {
            
            Class someClass = object;
            return [someClass isMineNSNetworkError:nativeError];
        }];
    }
    
    if (class == Nil) {
        
        class = [JNSNetworkError class];
    }
    
    JNSNetworkError *result = [[class alloc] initWithContext:context nativeError:nativeError];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    JNSNetworkError *copy = [super copyWithZone:zone];
    
    if (copy) {
        
        copy->_nativeError = [_nativeError copyWithZone:zone];
        copy->_context     = [_context     copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ nativeError:%@ context:%@", [self localizedDescription], _nativeError, _context];
}

@end
