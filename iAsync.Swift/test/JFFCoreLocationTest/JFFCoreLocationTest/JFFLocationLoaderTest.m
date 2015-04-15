
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@interface JFFLocationLoaderTest : GHAsyncTestCase
@end

@implementation JFFLocationLoaderTest

- (void)testGetLocation
{
    __block CLLocation *location;
    
    void(^testBlock)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishBLock) {
        
        JFFAsyncOperation loader = [JFFLocationLoader locationLoaderWithAccuracy:kCLLocationAccuracyKilometer];
        loader(nil, nil, ^(id result, NSError *error) {
            
            location = result;
            
            finishBLock();
        });
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd
                                           timeout:10.];
    
    GHAssertNotNil(location, nil);
}

- (void)testGetPlacemarks
{
    __block CLPlacemark *placemark;
    
    void(^testBlock)(JFFSimpleBlock) = ^void(JFFSimpleBlock finishBLock) {
        
        JFFAsyncOperation loader = [JFFPlacemarksLoader placemarkLoaderForCurrentLocationWithAccuracy:kCLLocationAccuracyKilometer];
        loader(nil, nil, ^(id result, NSError *error) {
            
            placemark = result;
            
            finishBLock();
        });
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd
                                           timeout:10.];
    
    GHAssertNotNil(placemark, nil);
}

@end
