#import "NSNumber+FSStorable.h"

#import "NSString+PathExtensions.h"
#import "NSString+FileAttributes.h"

@implementation NSNumber (FSStorable)

+ (instancetype)newLongLongNumberWithContentsOfFile:(NSString *)fileName
{
    NSParameterAssert(fileName);
    
    fileName = [NSString documentsPathByAppendingPathComponent:fileName];
    NSString *string = [[NSString alloc] initWithContentsOfFile:fileName
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    double scannedNumber = 0;
    if (string) {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner scanDouble:&scannedNumber];
    }
    NSNumber *result = @(scannedNumber);
    return result;
}

+ (instancetype)newDoubleWithContentsOfFile:(NSString *)fileName
{
    NSParameterAssert(fileName);
    
    fileName = [NSString documentsPathByAppendingPathComponent:fileName];
    NSString *string = [[NSString alloc] initWithContentsOfFile:fileName
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    long long scannedNumber = 0;
    if (string) {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner scanLongLong:&scannedNumber];
    }
    NSNumber *result = @(scannedNumber);
    return result;
}

- (BOOL)saveNumberToFile:(NSString *)fileName
{
    NSParameterAssert(fileName);
    
    NSString *string = [self description];
    
    fileName = [NSString documentsPathByAppendingPathComponent:fileName];
    BOOL result = [string writeToFile:fileName
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:NULL];
    if (result)
        [fileName addSkipBackupAttribute];
    
    return result;
}

@end
