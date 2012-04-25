#import <GHUnitIOS/GHUnit.h>

@interface JAlertTest : GHTestCase
@end
 
@implementation JAlertTest

-(void)setUp
{
}

-(void)tearDown
{    
} 
 
-(void)testSimplePass
{

}
 
-(void)testSimpleFail
{
   GHAssertTrue(NO, nil);
}
 
@end
