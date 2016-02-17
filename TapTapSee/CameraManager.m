//
//  CameraManager.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <sys/utsname.h>
#import "CameraManager.h"
#import "Config.h"

static const int kTTSAbnormalResultsError = 81;

@interface CameraManager ()
@property (nonatomic, retain, readwrite) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation CameraManager

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCaptureSessionRuntimeError:)
                                                     name:AVCaptureSessionRuntimeErrorNotification
                                                   object:nil];
        
        cameraManagerQueue = dispatch_queue_create("com.imagesearcher.CameraManager", NULL);
        captureSession = [[AVCaptureSession alloc] init];
        
        // Add video input
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (videoDevice) {
            NSError *error;
            AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
            if (videoIn) {
                if ([captureSession canAddInput:videoIn])
                    [captureSession addInput:videoIn];
                else
                    DDLogDebug(@"Couldn't add video input");
            } else {
                [self showCameraPrivacyError];
                DDLogDebug(@"Couldn't create video input: %@", error.localizedDescription);
            }
            
            focusObserver = [[FocusObserver alloc] initWithVideoDevice:videoDevice];
        } else {
            DDLogDebug(@"Couldn't create video capture device");
        }

        // Add metadata output
        metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [captureSession addOutput:metadataOutput];
        [metadataOutput setMetadataObjectTypes:[metadataOutput availableMetadataObjectTypes]];
        
        // Add still image output
        stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
        [captureSession addOutput:stillImageOutput];
        
        // Set up video preview layer
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        /*
         Preset                                3G        3GS     4 back  4 front
         AVCaptureSessionPresetHigh       400x304    640x480   1280x720  640x480
         AVCaptureSessionPresetMedium     400x304    480x360    480x360  480x360
         AVCaptureSessionPresetLow        400x304    192x144    192x144  192x144
         AVCaptureSessionPreset640x480         NA    640x480    640x480  640x480
         AVCaptureSessionPreset1280x720        NA         NA   1280x720       NA
         AVCaptureSessionPresetPhoto    1600x1200  2048x1536  2592x1936  640x480
         */
        
        /*
         if ([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])    DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetPhoto");
         if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow])      DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetLow");
         if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])   DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetMedium");
         if ([captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])     DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetHigh");
         if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])  DDLogDebug(@"canSetSessionPreset AVCaptureSessionPreset640x480");
         if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) DDLogDebug(@"canSetSessionPreset AVCaptureSessionPreset1280x720");
         */
        
        sessionPreset = captureSession.sessionPreset;
        
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])
            sessionPreset = AVCaptureSessionPresetPhoto;
        
        if ([captureSession canSetSessionPreset:sessionPreset])
            captureSession.sessionPreset = sessionPreset;
        else
            DDLogDebug(@"Can not set AVCaptureSession sessionPreset, using default %@", captureSession.sessionPreset);
        
        DDLogDebug(@"AVCaptureSession sessionPreset %@", captureSession.sessionPreset);
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device isFlashAvailable] && device.flashMode != AVCaptureFlashModeAuto) {
            [captureSession beginConfiguration];
            [device lockForConfiguration:nil];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults boolForKey:DEFAULT_FLASH_KEY])
                [device setFlashMode:AVCaptureFlashModeAuto];
            else
                [device setFlashMode:AVCaptureFlashModeOff];
            
            [device unlockForConfiguration];
            [captureSession commitConfiguration];
        }
    }
    
    return self;
}

- (void)dealloc
{
    DDLogDebug(@"dealloc'ed");

    [self stopCamera];
    
    if ([captureSession.outputs containsObject:metadataOutput])
        [captureSession removeOutput:metadataOutput];
    
    [metadataOutput setMetadataObjectsDelegate:nil queue:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Capture control

- (void)captureStillFrame
{
    AVCaptureConnection *videoConnection = [self videoConnection];
    if (videoConnection == nil) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kTTSAbnormalResultsError
                                         userInfo:@{NSLocalizedDescriptionKey : @"Video connection not established" }];
        
        [self.delegate cameraManager:self didFailToCaptureStillFrameWithError:error];
        return;
    }
    
    if ([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:[self cameraOrientation]];
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError* error)
     {
         if (imageSampleBuffer != nil) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self.delegate cameraManager:self didCaptureStillFrame:image];
         } else {
             [self.delegate cameraManager:self didFailToCaptureStillFrameWithError:error];
         }
     }];
}

- (void)startCamera
{
    if (!captureSession.running)
        [captureSession startRunning];
}

- (void)stopCamera
{
    if (captureSession.running)
        [captureSession stopRunning];
}

- (void)showCameraPrivacyError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera Access", @"")
                                                    message:NSLocalizedString(@"Make sure privacy settings for TapTapSee are enabled under Settings > Privacy > Camera.", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Accept", @"")
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark Utilities

- (AVCaptureConnection *)videoConnection
{
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                return connection;
                break;
            }
        }
    }
    
    return nil;
}

- (NSString *)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (AVCaptureVideoOrientation)cameraOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    AVCaptureVideoOrientation newOrientation;
    
    // AVCapture and UIDevice have opposite meanings for landscape left and right
    // (AVCapture orientation is the same as UIInterfaceOrientation)
    if (deviceOrientation == UIDeviceOrientationPortrait)           newOrientation = AVCaptureVideoOrientationPortrait;           else
    if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) newOrientation = AVCaptureVideoOrientationPortraitUpsideDown; else
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft)      newOrientation = AVCaptureVideoOrientationLandscapeRight;     else
    if (deviceOrientation == UIDeviceOrientationLandscapeRight)     newOrientation = AVCaptureVideoOrientationLandscapeLeft;      else
    if (deviceOrientation == UIDeviceOrientationUnknown)            newOrientation = AVCaptureVideoOrientationPortrait;           else
        newOrientation = AVCaptureVideoOrientationPortrait;
    return newOrientation;
}

- (void)onCaptureSessionRuntimeError:(NSNotification *)n
{
    DDLogDebug(@"AVCaptureSessionRuntimeError: %@", [n.userInfo objectForKey:AVCaptureSessionErrorKey]);
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate implementation

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.delegate cameraManager:self didCaptureMetadata:metadataObjects];
}

@end
