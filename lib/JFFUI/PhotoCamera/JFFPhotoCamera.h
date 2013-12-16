#import <Foundation/Foundation.h>

#include <JFFUI/PhotoCamera/JFFPhotoCameraType.h>
#include <JFFUI/PhotoCamera/JFFCameraFlashModeType.h>

typedef void(^PhotoCameraMakePhotoResult)(UIImage *image, NSError *error);

typedef NS_ENUM(NSUInteger, JFFAVCaptureVideoOrientation)
{
    JFFAVCaptureVideoOrientationPortrait           = 1,
    JFFAVCaptureVideoOrientationPortraitUpsideDown = 2,
    JFFAVCaptureVideoOrientationLandscapeRight     = 3,
    JFFAVCaptureVideoOrientationLandscapeLeft      = 4,
};

@class AVCaptureVideoPreviewLayer;

@interface JFFPhotoCamera : NSObject

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic) JFFCameraFlashModeType flashMode;
@property (nonatomic) JFFPhotoCameraType photoCameraType;
@property (nonatomic) BOOL fixOrientation; //default is YES
@property (nonatomic) BOOL rotateImage; //default is YES

@property (nonatomic) JFFAVCaptureVideoOrientation videoOrientation;

- (instancetype)initPhotoCameraType:(JFFPhotoCameraType)photoCameraType;

+ (NSArray *)allActiveCameras;

- (void)startRunning;
- (void)stopRunning;

- (BOOL)isRunning;

- (void)makePhotoWithCallback:(PhotoCameraMakePhotoResult)callback;

@end
