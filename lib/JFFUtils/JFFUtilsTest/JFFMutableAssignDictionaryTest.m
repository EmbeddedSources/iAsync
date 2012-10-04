#import "JFFMutableAssignDictionaryTest.h"

@implementation JFFMutableAssignDictionaryTest

-(void)testMutableAssignDictionaryAssignIssue
{
    JFFMutableAssignDictionary *dict;
    __block BOOL targetDeallocated = NO;
    
    {
        NSObject *target = [NSObject new];
        
        [target addOnDeallocBlock:^void(void) {
            targetDeallocated = YES;
        } ];
        
        dict = [JFFMutableAssignDictionary new];
        [dict setObject:target forKey:@"1"];
        
        STAssertTrue(1 == [dict count], @"Contains 1 object");
    }
    
    STAssertTrue(targetDeallocated, @"Target should be dealloced");
    STAssertTrue(0 == [dict count], @"Empty array");
}

-(void)testMutableAssignDictionaryFirstRelease
{
    __block BOOL dict_deallocated_ = NO;
    {
        JFFMutableAssignDictionary* dict_ = [ JFFMutableAssignDictionary new ];
        
        [dict_ addOnDeallocBlock:^void(void) {
            dict_deallocated_ = YES;
        }];
        
        NSObject *target_ = [NSObject new];
        [ dict_ setObject: target_ forKey: @"1" ];
    }
    
    STAssertTrue( dict_deallocated_, @"Target should be dealloced" );
}

-(void)testObjectForKey
{
    @autoreleasepool {
        JFFMutableAssignDictionary *dict = [JFFMutableAssignDictionary new];
        
        __block BOOL target_deallocated = NO;
        @autoreleasepool {
            NSObject *object1 = [NSObject new];
            NSObject *object2 = [NSObject new];
            
            [object1 addOnDeallocBlock: ^void( void ) {
                 target_deallocated = YES;
             } ];
            
            [dict setObject:object1 forKey:@"1"];
            [dict setObject:object2 forKey:@"2"];
            
            STAssertTrue(dict[@"1" ] == object1, @"Dict contains object_");
            STAssertTrue(dict[@"2" ] == object2, @"Dict contains object_");
            STAssertTrue(dict[@"3" ] == nil, @"Dict no contains object for key \"2\"");
            
            __block NSUInteger count_ = 0;
            
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 if ( [ key isEqualToString: @"1" ] ) {
                     STAssertTrue(obj == object1, nil);
                     ++count_;
                 } else if ([key isEqualToString:@"2"]) {
                     STAssertTrue(obj == object2, nil);
                     ++count_;
                 } else {
                     STFail( @"should not be reached" );
                 }
             } ];
            
            STAssertTrue( count_ == 2, @"Dict no contains object for key \"2\"" );
        }
        
        STAssertTrue(target_deallocated, @"Target should be dealloced");
        STAssertTrue(0 == [dict count], @"Empty dict");
    }
}

-(void)testReplaceObjectInDict
{
    JFFMutableAssignDictionary *dict = [JFFMutableAssignDictionary new];
    
    @autoreleasepool {
        __block BOOL replacedObjectDealloced = NO;
        NSObject *object = nil;
        
        @autoreleasepool {
            NSObject* replacedObject = [ NSObject new ];
            [replacedObject addOnDeallocBlock: ^void() {
                replacedObjectDealloced = YES;
            } ];
            
            object = [NSObject new];
            
            dict[@"1"] = replacedObject;
            
            STAssertTrue(dict[@"1"] == replacedObject, @"Dict contains object_");
            STAssertTrue(dict[@"2"] == nil, @"Dict no contains object for key \"2\"");
            
            dict[@"1"] = object;
            STAssertTrue([dict objectForKey:@"1"] == object, @"Dict contains object_");
        }
        
        STAssertTrue(replacedObjectDealloced, nil);
        
        NSObject *currentObject = [dict objectForKey:@"1"];
        STAssertTrue(currentObject == object, nil);
    }
    
    STAssertTrue(0 == [dict count], @"Empty dict");
}

- (void)testMapMethod
{
    JFFMutableAssignDictionary *dict = [JFFMutableAssignDictionary new];
    
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    
    NSDictionary *result = [dict map:^id(id key, id object) {
        NSUInteger num = [object unsignedIntegerValue];
        return @(num * [key integerValue]);
    }];
    
    STAssertTrue([result count] == 3, nil);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        STAssertFalse([result isKindOfClass:[NSMutableDictionary class]], nil);
    STAssertTrue([result isKindOfClass:[NSDictionary class]], nil);
    
    STAssertEqualObjects(@1, result[@"1"], nil);
    STAssertEqualObjects(@4, result[@"2"], nil);
    STAssertEqualObjects(@9, result[@"3"], nil);
    
    STAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    }, nil);
}

- (void)testEnumerateKeysAndObjectsUsingBlock
{
    NSDictionary *patternDict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    JFFMutableAssignDictionary *dict = [JFFMutableAssignDictionary new];
    
    [patternDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        dict[key] = obj;
    }];
    
    __block NSUInteger count = 0;
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        resultDict[key] = obj;
        STAssertEqualObjects(obj, patternDict[key], nil);
    }];
    
    STAssertTrue(count == 3, nil);
    STAssertEqualObjects(resultDict, patternDict, nil);
    
    count = 0;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        if (count == 2)
            *stop = YES;
    }];
    
    STAssertTrue(count == 2, nil);
}

@end
