#import "TypeSignatureArgumentsOffsetsTest.h"

#include "JFFRuntimeAddiotions.h"

@implementation TypeSignatureArgumentsOffsetsTest

static NSArray *typeEncodingOffsets(const char *signature)
{
    assert(signature != NULL);
    
    NSMutableArray *result = [NSMutableArray new];
    
    while (strlen(signature) != 0) {
        
        signature = NSGetSizeAndAlignment(signature, NULL, NULL);
        
        if (strlen(signature) == 0)
            break;
        
        long long value;
        sscanf(signature, "%lld", &value);
        
        [result addObject:@(value)];
    }
    
    return result;
}

- (void)testGetOffsets
{
    {
        id block = ^NSObject *(id _self, NSUInteger arg, CGPoint point) {
            
            return nil;
        };
        [block description];
        const char *sinature  = "@20@?0@4I8{CGPoint=ff}12";
        //block_getTypeEncoding(block);
        
        NSArray *arr = @[@20, @0, @4, @8, @12];
        
        STAssertEqualObjects(arr, typeEncodingOffsets(sinature), nil);
    }
    
    {
        id block = ^NSNumber *(id _self, float arg) {
            
            return nil;
        };
        [block description];
        const char *sinature  = "@12@?0@4f8";//block_getTypeEncoding(block);
        //block_getTypeEncoding(block);
        
        NSArray *arr = @[@12, @0, @4, @8];
        
        STAssertEqualObjects(arr, typeEncodingOffsets(sinature), nil);
    }
    
    {
        id block = ^(id _self, NSUInteger arg, CGPoint point) {
            
            return nil;
        };
        [block description];
        const char *sinature  = "^v20@?0@4I8{CGPoint=ff}12";//block_getTypeEncoding(block);
        NSLog(@"blockSinature: %s", sinature);
        
        NSArray *arr = @[@20, @0, @4, @8, @12];
        
        STAssertEqualObjects(arr, typeEncodingOffsets(sinature), nil);
    }
}

@end
