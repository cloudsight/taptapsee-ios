//
//  CaptureManagerDelegate.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CameraManager;

@protocol CameraManagerDelegate <NSObject>

- (void)cameraManager:(CameraManager *)manager didCaptureStillFrame:(UIImage *)image;
- (void)cameraManager:(CameraManager *)manager didCaptureMetadata:(NSArray *)metadataObjects;
- (void)cameraManager:(CameraManager *)manager didFailToCaptureStillFrameWithError:(NSError *)error;

@end
