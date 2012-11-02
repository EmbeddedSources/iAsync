#import <JFFCoreLocation/Errors/JFFCoreLocationError.h>

#import <Foundation/Foundation.h>

@class CLLocation;

@interface JFFNoPlacemarksError : JFFCoreLocationError

@property (nonatomic) CLLocation *location;

@end
