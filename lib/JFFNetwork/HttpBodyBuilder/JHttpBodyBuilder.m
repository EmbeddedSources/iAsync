#import "JHttpBodyBuilder.h"

@implementation JHttpBodyBuilder

+ (NSString *)tmpFileForUploadStreamWithDataForFilePath:(NSString *)dataFilePath
                                               boundary:(NSString *)boundary
                                                   name:(NSString *)name
                                               fileName:(NSString *)fileName
                                          dictWithParam:(NSDictionary *)dictWithParam
{
    NSString *filePath;
    
    @autoreleasepool {
        
        filePath = [NSString createUuid];
        filePath = [NSString cachesPathByAppendingPathComponent:filePath];
        const char *filePathPtr = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
        
        FILE *file = fopen(filePathPtr, "w+");
        
        @autoreleasepool
        {
            {
                NSString *boundaryStr = [[NSString alloc] initWithFormat:@"--%@\r\n", boundary];
                NSData *boundaryData = [boundaryStr dataUsingEncoding:NSUTF8StringEncoding];
                fwrite([boundaryData bytes], 1, [boundaryData length], file);
            }
            //[result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            {
                NSString *contentDisposition = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, fileName];
                NSData *contentDispositionData = [contentDisposition dataUsingEncoding:NSUTF8StringEncoding];
                fwrite([contentDispositionData bytes], 1, [contentDispositionData length], file);
            }
            //[result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            
            {
                NSString *contentType = @"Content-Type: application/octet-stream\r\n\r\n";
                NSData *contentTypeData = [contentType dataUsingEncoding:NSUTF8StringEncoding];
                fwrite([contentTypeData bytes], 1, [contentTypeData length], file);
            }
            //[result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            {
                FILE *uploadDataFile = fopen([dataFilePath cStringUsingEncoding:NSUTF8StringEncoding],
                                        "r");
                
                uint8_t buffer[10*1024];
                const size_t bufferSize = sizeof(buffer)/sizeof(buffer[0]);
                
                size_t readBytes = 0;
                
                while ((readBytes = fread((void* __restrict)&buffer[0], 1, bufferSize, uploadDataFile)) != 0) {
                    
                    fwrite(buffer, 1, readBytes, file);
                }
                
                fclose(uploadDataFile);
            }
            //[result appendData:data];
            
            {
                NSString *boundaryStr = [[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary];
                NSData *boundaryData = [boundaryStr dataUsingEncoding:NSUTF8StringEncoding];
                fwrite([boundaryData bytes], 1, [boundaryData length], file);
            }
            //[result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        {
            [dictWithParam enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                
                @autoreleasepool
                {
                    {
                        NSString *boundaryStr = [[NSString alloc] initWithFormat:@"--%@\r\n", boundary];
                        NSData *boundaryData = [boundaryStr dataUsingEncoding:NSUTF8StringEncoding];
                        fwrite([boundaryData bytes], 1, [boundaryData length], file);
                    }
                    //[self appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    {
                        NSString *contentDisposition = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
                        NSData *contentDispositionData = [contentDisposition dataUsingEncoding:NSUTF8StringEncoding];
                        fwrite([contentDispositionData bytes], 1, [contentDispositionData length], file);
                    }
                    //[self appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    {
                        NSString *objStr = [obj description];
                        NSData *objData = [objStr dataUsingEncoding:NSUTF8StringEncoding];
                        fwrite([objData bytes], 1, [objData length], file);
                    }
                    //[self appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    {
                        NSString *boundaryStr = [[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary];
                        NSData *boundaryData = [boundaryStr dataUsingEncoding:NSUTF8StringEncoding];
                        fwrite([boundaryData bytes], 1, [boundaryData length], file);
                    }
                    //[self appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }];
        }
        
        fclose(file);
    }
    
    return filePath;
}

@end
