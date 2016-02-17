//
//  CameraManager.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMSampleBuffer.h>
#import "CameraManagerDelegate.h"
#import "FocusObserver.h"


@interface CameraManager : NSObject <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureMetadataOutput *metadataOutput;
    AVCaptureStillImageOutput *stillImageOutput;
    FocusObserver *focusObserver;

    NSString *sessionPreset;
    
    dispatch_queue_t cameraManagerQueue;
}

@property (nonatomic, assign) id<CameraManagerDelegate> delegate;
@property (nonatomic, retain, readonly) AVCaptureVideoPreviewLayer *previewLayer;

- (void)startCamera;
- (void)stopCamera;
- (void)captureStillFrame;

@end