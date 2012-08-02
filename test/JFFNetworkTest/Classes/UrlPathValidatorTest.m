#import <JFFNetwork/Detail/NSUrlLocationValidator.h>

@interface UrlPathValidatorTest : GHTestCase
@end



@implementation UrlPathValidatorTest

-(void)testUrlCannotBeAPath
{
    NSString* location_ = nil;
    BOOL result_ = NO;
    
    {
        location_ = @"http://abrakadabra.com/?f";
        result_ = [ NSUrlLocationValidator isValidLocation: location_ ];
        
        GHAssertFalse( result_, @"expected FALSE for 'http://abrakadabra.com/?f' " );
    }


    {
        location_ = @"http://www.google.com.ua/";
        result_ = [ NSUrlLocationValidator isValidLocation: location_ ];
        
        GHAssertFalse( result_, @"expected FALSE for 'http://abrakadabra.com/?f' " );
    }
}

-(void)testNilPathIsInvalid
{
    BOOL result_ = NO;
    
    {
        result_ = [ NSUrlLocationValidator isValidLocation: nil ];        
        GHAssertFalse( result_, @"expected FALSE for 'nil' " );
    }
}

-(void)testEmptyPathIsInvalid
{
    BOOL result_ = NO;
    
    {
        result_ = [ NSUrlLocationValidator isValidLocation: @"" ];        
        GHAssertFalse( result_, @"expected FALSE for '{empty}' " );
    }
}

-(void)testPathMustStartWithSlash
{
    NSString* location_ = nil;
    BOOL result_ = NO;
    
    {
        location_ = @"abrakadabra";
        result_ = [ NSUrlLocationValidator isValidLocation: location_ ];        
        GHAssertFalse( result_, @"expected FALSE for 'abrakadabra' " );
    }
    
    {
        location_ = @"/abrakadabra";
        result_ = [ NSUrlLocationValidator isValidLocation: location_ ];        
        GHAssertTrue( result_, @"expected TRUE for '/abrakadabra' " );
    }
}

@end
