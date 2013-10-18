#import <Foundation/Foundation.h>

@protocol JNHttpDecoder <NSObject>

- (NSData *)decodeData:(NSData *)encodedData
                 error:(NSError **)outError;

- (BOOL)closeWithError:(NSError **)outError;

@end
