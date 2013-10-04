#import "NSNumber+FSStorable.h"

#import "NSString+PathExtensions.h"
#import "NSString+FileAttributes.h"

@implementation NSNumber (FSStorable)

+ (instancetype)newNumberWithDocumentContentsOfFile:(NSString *)fileName
                                            scanner:(NSNumber *(^)(NSString *))scanner
{
    NSParameterAssert(fileName && scanner);
    
    NSString *path = [NSString documentsPathByAppendingPathComponent:fileName];
    
    NSString *string = [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    return string?scanner(string):nil;
}

+ (instancetype)newLongLongNumberWithContentsOfFile:(NSString *)fileName
{
    NSNumber *(^scanner)(NSString *) = ^NSNumber *(NSString *string) {
        
        double scannedNumber = 0;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner scanDouble:&scannedNumber];
        NSNumber *result = @(scannedNumber);
        return result;
    };
    
    return [self newNumberWithDocumentContentsOfFile:fileName
                                             scanner:scanner];
}

+ (instancetype)newDoubleWithContentsOfFile:(NSString *)fileName
{
    NSNumber *(^scanner)(NSString *) = ^NSNumber *(NSString *string) {
        
        long long scannedNumber = 0;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner scanLongLong:&scannedNumber];
        NSNumber *result = @(scannedNumber);
        return result;
    };
    
    return [self newNumberWithDocumentContentsOfFile:fileName
                                             scanner:scanner];
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
