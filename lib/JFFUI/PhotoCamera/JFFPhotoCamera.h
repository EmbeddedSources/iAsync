#import <Foundation/Foundation.h>

#include <JFFUI/PhotoCamera/JFFPhotoCameraType.h>
#include <JFFUI/PhotoCamera/JFFCameraFlashModeType.h>

typedef void(^PhotoCameraMakePhotoResult)(UIImage *image, NSError *error);

enum {
    JFFAVCaptureVideoOrientationPortrait           = 1,
    JFFAVCaptureVideoOrientationPortraitUpsideDown = 2,
    JFFAVCaptureVideoOrientationLandscapeRight     = 3,
    JFFAVCaptureVideoOrientationLandscapeLeft      = 4,
};
typedef NSInteger JFFAVCaptureVideoOrientation;

@class AVCaptureVideoPreviewLayer;

@interface JFFPhotoCamera : NSObject

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//TODO create it lazy
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic) JFFCameraFlashModeType flashMode;
@property (nonatomic) JFFPhotoCameraType photoCameraType;
@property (nonatomic) BOOL fixOrientation;

@property (nonatomic) JFFAVCaptureVideoOrientation videoOrientation;

- (instancetype)initPhotoCameraType:(JFFPhotoCameraType)photoCameraType;

- (void)startRunning;
- (void)stopRunning;

- (void)makePhotoWithCallback:(PhotoCameraMakePhotoResult)callback;

@end
