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
        
        XCTAssertTrue(1 == [dict count], @"Contains 1 object");
    }
    
    XCTAssertTrue(targetDeallocated, @"Target should be dealloced");
    XCTAssertTrue(0 == [dict count], @"Empty array");
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
    
    XCTAssertTrue( dict_deallocated_, @"Target should be dealloced" );
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
            
            XCTAssertTrue(dict[@"1" ] == object1, @"Dict contains object_");
            XCTAssertTrue(dict[@"2" ] == object2, @"Dict contains object_");
            XCTAssertTrue(dict[@"3" ] == nil, @"Dict no contains object for key \"2\"");
            
            __block NSUInteger count_ = 0;
            
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 if ( [ key isEqualToString: @"1" ] ) {
                     XCTAssertTrue(obj == object1);
                     ++count_;
                 } else if ([key isEqualToString:@"2"]) {
                     XCTAssertTrue(obj == object2);
                     ++count_;
                 } else {
                     XCTFail( @"should not be reached" );
                 }
             } ];
            
            XCTAssertTrue( count_ == 2, @"Dict no contains object for key \"2\"" );
        }
        
        XCTAssertTrue(target_deallocated, @"Target should be dealloced");
        XCTAssertTrue(0 == [dict count], @"Empty dict");
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
            
            XCTAssertTrue(dict[@"1"] == replacedObject, @"Dict contains object_");
            XCTAssertTrue(dict[@"2"] == nil, @"Dict no contains object for key \"2\"");
            
            dict[@"1"] = object;
            XCTAssertTrue([dict objectForKey:@"1"] == object, @"Dict contains object_");
        }
        
        XCTAssertTrue(replacedObjectDealloced);
        
        NSObject *currentObject = [dict objectForKey:@"1"];
        XCTAssertTrue(currentObject == object);
    }
    
    XCTAssertTrue(0 == [dict count], @"Empty dict");
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
    
    XCTAssertTrue([result count] == 3);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        XCTAssertFalse([result isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertEqualObjects(@1, result[@"1"]);
    XCTAssertEqualObjects(@4, result[@"2"]);
    XCTAssertEqualObjects(@9, result[@"3"]);
    
    XCTAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    });
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
        XCTAssertEqualObjects(obj, patternDict[key]);
    }];
    
    XCTAssertTrue(count == 3);
    XCTAssertEqualObjects(resultDict, patternDict);
    
    count = 0;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        if (count == 2)
            *stop = YES;
    }];
    
    XCTAssertTrue(count == 2);
}

@end
