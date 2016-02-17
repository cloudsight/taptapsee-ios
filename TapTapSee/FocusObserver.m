//
//  FocusObserver.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "FocusObserver.h"
#import "Config.h"
#import "SpeakQueue.h"

@implementation FocusObserver

- (id)initWithVideoDevice:(AVCaptureDevice *)avcd
{
    self = [super init];
    if (self) {
        // Turn on the sound
        [self initializeAudioPlayer];

        // Setup the AVCaptureDevice observing
        self.avCaptureDevice = avcd;
        [self.avCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self.avCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
}

- (void)initializeAudioPlayer
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
        NSLog(@"Error setting up audio session: %@", error);

    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"camera-focus-beep-01" ofType:@"mp3"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFile] error:&error];
    if (error)
        NSLog(@"Failed to init 'focus acquired' sound: %@", error);
    
    [audioPlayer prepareToPlay];
}

- (void)focusAcquired
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:DEFAULT_FOCUS_LOCK_SOUND_KEY]) {
        // Check to see if we've got VoiceOver queued so we don't interrupt it
        if (![[SpeakQueue sharedQueue] isBusy])
            [audioPlayer play];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL wasAdjustingFocus = [[change objectForKey:NSKeyValueChangeOldKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        DDLogDebug(@"Focusing %@ -> %@", wasAdjustingFocus ? @"YES" : @"NO", adjustingFocus ? @"YES" : @"NO");
//        NSLog(@"Change dict: %@", change);
        
        if (wasAdjustingFocus && !adjustingFocus) {
            DDLogDebug(@"Focus acquired");
            [self focusAcquired];
        }
    }
}

@end
