#import "JFFPhotoCamera.h"

#import "UIImage+RotateImage.h"
#import "UIImage+FixOrientation.h"

#import <AVFoundation/AVFoundation.h>

#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait (dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)

@implementation UIImage (JFFPhotoCamera)

- (UIImage *)fixOrientationForPhotoCameraType:(JFFPhotoCameraType)photoCameraType
                               fixOrientation:(BOOL)fixOrientation
                                  rotateImage:(BOOL)rotateImage
{
    UIImage *result = self;
    
    if (fixOrientation)
        result = [result fixOrientation];
    
    if (isLandscape) {
        
        if (rotateImage) {
        
            const CGFloat radians = M_PI_2 * ((photoCameraType == JFFPhotoCameraFront)?1:-1);
            result = [result rotatedImageWithRadians:radians];
        }
        else if (photoCameraType == JFFPhotoCameraFront) {
            
            const CGFloat radians = M_PI;
            result = [result rotatedImageWithRadians:radians];
        }
    }
    
    return result;
}

@end

@implementation JFFPhotoCamera
{
    AVCaptureSession          *_captureSession;
    AVCaptureDeviceInput      *_frontCamInput;
    AVCaptureDeviceInput      *_backCamInput;
    AVCaptureStillImageOutput *_camImageOutput;
    AVCaptureDevice *_frontCameraDevice;
    AVCaptureDevice *_backCameraDevice;
    
    AVCaptureVideoPreviewLayer *_internalCaptureVideoPreviewLayer;
    
    AVCaptureFlashMode _flashMode;
}

@synthesize photoCameraType = _photoCameraType;

@dynamic captureVideoPreviewLayer;

- (instancetype)init
{
    return [self initPhotoCameraType:JFFPhotoCameraBack];
}

- (instancetype)initPhotoCameraType:(JFFPhotoCameraType)photoCameraType
{
    self = [super init];
    
    if (self) {
        
        _fixOrientation = YES;
        _rotateImage    = YES;
        _photoCameraType = photoCameraType;
        
        [self initCaptureSessions];
        [self setupCaptureInputs];
        [self setupImageOutput];
    }
    
    return self;
}

- (void)initCaptureSessions
{
    _captureSession = [AVCaptureSession new];
}

- (void)setupCaptureInputs
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices) {
        
        if (device.position == AVCaptureDevicePositionFront) {
            _frontCameraDevice = device;
            break;
        }
    }
    
    NSError *error;
    _frontCamInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCameraDevice error:&error];
    
    NSAssert(!error, @"frontCamInput not intialized");
    
    _backCameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _backCamInput = [AVCaptureDeviceInput deviceInputWithDevice:_backCameraDevice error:&error];
    
    NSAssert(!error, @"frontCamInput not intialized");
    
    [_captureSession addInput:(_photoCameraType == JFFPhotoCameraFront)?_frontCamInput:_backCamInput];
}

- (CALayer *)captureVideoPreviewLayer
{
    if (!_internalCaptureVideoPreviewLayer) {
        
        _internalCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_internalCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    
    return _internalCaptureVideoPreviewLayer;
}

- (void)setupImageOutput
{
    _camImageOutput  = [AVCaptureStillImageOutput new];
    
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
    
    [_camImageOutput setOutputSettings:outputSettings];
    
    [_captureSession addOutput:_camImageOutput];
}

#pragma mark - Properties

- (NSString *)sessionPreset
{
    return _captureSession.sessionPreset;
}

- (void)setSessionPreset:(NSString *)sessionPreset
{
    _captureSession.sessionPreset = sessionPreset;
}

- (JFFAVCaptureVideoOrientation)videoOrientation
{
    AVCaptureConnection *videoConnection = [self videoConnectionFromImageOutput:_camImageOutput];
    return videoConnection.videoOrientation;
}

- (void)setVideoOrientation:(JFFAVCaptureVideoOrientation)videoOrientation
{
    AVCaptureConnection *videoConnection = [self videoConnectionFromImageOutput:_camImageOutput];
    videoConnection.videoOrientation = videoOrientation;
}

- (JFFCameraFlashModeType)flashMode
{
    //TODO check is front camera
    return _backCameraDevice.flashMode == AVCaptureFlashModeAuto
    ? JFFCameraFlashModeAuto
    : _backCameraDevice.flashMode == AVCaptureFlashModeOn
    ? JFFCameraFlashModeOn
    : JFFCameraFlashModeOff;
}

- (void)setFlashMode:(JFFCameraFlashModeType)flashMode
{
    AVCaptureFlashMode deviceFlashMode = flashMode == JFFCameraFlashModeAuto
    ? AVCaptureFlashModeAuto
    : flashMode == JFFCameraFlashModeOn
    ? AVCaptureFlashModeOn
    : AVCaptureFlashModeOff;
    
    NSError *error;
    [_backCameraDevice lockForConfiguration:&error];
    [error writeErrorWithJFFLogger];
    
    _backCameraDevice.flashMode = deviceFlashMode;
    
    [_backCameraDevice unlockForConfiguration];
}

- (JFFPhotoCameraType)photoCameraType
{
    return _photoCameraType;
}

- (void)setPhotoCameraType:(JFFPhotoCameraType)photoCameraType
{
    if (_photoCameraType == photoCameraType)
        return;
    
    BOOL frontCameraWasActive = (_photoCameraType == JFFPhotoCameraFront);
    
    _photoCameraType = photoCameraType;
    
    BOOL isRunning = _captureSession.isRunning;
    
    if (isRunning)
        [_captureSession stopRunning];
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput: frontCameraWasActive?_frontCamInput:_backCamInput];
    [_captureSession addInput:    frontCameraWasActive?_backCamInput :_frontCamInput];
    
    [_captureSession commitConfiguration];
    
    if (isRunning)
        [_captureSession startRunning];
}

- (void)startRunning
{
    NSParameterAssert(_captureSession);
    [_captureSession startRunning];
}

- (void)stopRunning
{
    NSParameterAssert(_captureSession);
    [_captureSession stopRunning];
}

- (AVCaptureConnection *)videoConnectionFromImageOutput:(AVCaptureStillImageOutput *)imageOutput
{
    AVCaptureConnection *videoConnection;
    
    for (AVCaptureConnection *connection in imageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    return videoConnection;
}

- (void)makePhotoWithCallback:(PhotoCameraMakePhotoResult)callback
{
    NSParameterAssert(callback);
    
    AVCaptureStillImageOutput *cameraImageOutput = _camImageOutput;
    
    AVCaptureConnection *videoConnection = [self videoConnectionFromImageOutput:cameraImageOutput];
    
    callback = [callback copy];
    
    BOOL fixOrientation = self.fixOrientation;
    BOOL rotateImage    = self.rotateImage;
    
    JFFPhotoCameraType photoCameraType = _photoCameraType;
    
    [cameraImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (error) {
            callback(nil, error);
            return;
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *photoImage = [[UIImage alloc] initWithData:imageData];//TODO101 pas jpegData file pass
        
        photoImage = [photoImage fixOrientationForPhotoCameraType:photoCameraType
                                                   fixOrientation:fixOrientation
                                                      rotateImage:rotateImage];
        
        callback(photoImage, nil);
    }];
}

@end
