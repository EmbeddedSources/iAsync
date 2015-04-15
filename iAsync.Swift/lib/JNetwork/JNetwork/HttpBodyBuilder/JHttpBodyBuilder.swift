//
//  JHttpBodyBuilder.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JHttpBodyBuilder : NSObject {
    
    public class func tmpFileForUploadStreamWithDataForFilePath(
        dataFilePath: String,
        boundary: String,
        name: String,
        fileName: String,
        dictWithParam: NSDictionary) -> String
    {
        var filePath: String!
        
        autoreleasepool {
            
            filePath = NSUUID().UUIDString
            filePath = NSString.cachesPathByAppendingPathComponent(filePath)
            let filePathPtr = filePath.cStringUsingEncoding(NSUTF8StringEncoding)
            
            let file = fopen(filePathPtr!, "w+")
            
            autoreleasepool {
                
                { () -> () in
                    
                    let boundaryStr  = "--\(boundary)\r\n"
                    let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
                    fwrite(boundaryData.bytes, 1, boundaryData.length, file)
                }();
                //[result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                { () -> () in
                    
                    let contentDisposition = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
                    let contentDispositionData = contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!
                    fwrite(contentDispositionData.bytes, 1, contentDispositionData.length, file)
                }();
                //[result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
                
                { () -> () in
                    let contentType     = "Content-Type: application/octet-stream\r\n\r\n";
                    let contentTypeData = contentType.dataUsingEncoding(NSUTF8StringEncoding)!
                    fwrite(contentTypeData.bytes, 1, contentTypeData.length, file)
                }();
                //[result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                { () -> () in
                    
                    let uploadDataFile = fopen(dataFilePath.cStringUsingEncoding(NSUTF8StringEncoding)!, "r")
                    
                    let bufferLength = 10*1024
                    var array = Array<UInt8>(count: Int(bufferLength), repeatedValue: 0)
                    
                    array.withUnsafeMutableBufferPointer({ (inout cArray: UnsafeMutableBufferPointer<UInt8>) -> () in
                        
                        let readFileChunk = { () -> Int in
                            return fread(cArray.baseAddress, 1, bufferLength, uploadDataFile)
                        }
                        var readBytes = readFileChunk()
                        while readBytes != 0 {
                            
                            fwrite(cArray.baseAddress, 1, readBytes, file)
                            readBytes = readFileChunk()
                        }
                    })
                    
                    fclose(uploadDataFile);
                }();
                //[result appendData:data];
                
                { () -> () in
                    
                    let boundaryStr  = "\r\n--\(boundary)\r\n"
                    let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
                    fwrite(boundaryData.bytes, 1, boundaryData.length, file)
                }()
                //[result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            { () -> () in
                
                for (key, value) in dictWithParam {
                    
                    autoreleasepool {
                        
                        { () -> () in
                            let boundaryStr  = "--\(boundary)\r\n"
                            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
                            fwrite(boundaryData.bytes, 1, boundaryData.length, file)
                        }();
                        //[self appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        { () -> () in
                            let contentDisposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                            let contentDispositionData = contentDisposition.dataUsingEncoding(NSUTF8StringEncoding)!
                            fwrite(contentDispositionData.bytes, 1, contentDispositionData.length, file)
                        }();
                        //[self appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                            
                        { () -> () in
                            let valueStr  = (value as! NSObject).description
                            let valueData = valueStr.dataUsingEncoding(NSUTF8StringEncoding)!
                            fwrite(valueData.bytes, 1, valueData.length, file)
                        }();
                        //[self appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        { () -> () in
                            let boundaryStr  = "\r\n--\(boundary)\r\n"
                            let boundaryData = boundaryStr.dataUsingEncoding(NSUTF8StringEncoding)!
                            fwrite(boundaryData.bytes, 1, boundaryData.length, file)
                        }()
                        //[self appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
            }()
            
            fclose(file)
        }
        
        return filePath
    }
}
