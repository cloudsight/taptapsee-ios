//
//  FocusObserver.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FocusObserver : NSObject
{
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic, retain) AVCaptureDevice *avCaptureDevice;

- (id)initWithVideoDevice:(AVCaptureDevice *)avcd;

@end
