//
//  SpeakQueue.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "SpeakQueue.h"

@implementation SpeakQueue

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedQueue];
}

- (id)init
{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] initWithCapacity:0];
        busy = NO;
        
        if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didFinishAnnouncement:)
                                                         name:UIAccessibilityAnnouncementDidFinishNotification
                                                       object:nil];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (SpeakQueue *)sharedQueue
{
    static SpeakQueue *sharedQueue = nil;
    if (!sharedQueue) {
        // Skip over alloc override below
        sharedQueue = [[super allocWithZone:nil] init];
    }
    
    return sharedQueue;
}

- (void)speak:(NSString *)message
{
    // Queue for speaking if we've got the notifications available to us
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) {
        busy = YES;
        [items addObject:message];
        if ([items count] == 1)
            [self dequeueAndSpeak];
    // Otherwise just post the notification straight to VoiceOver
    } else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    }
}

- (BOOL)isBusy
{
    return busy;
}

- (void)dequeueAndSpeak
{
    // Sanity check an empty queue
    if ([items count] == 0)
        return;

    // Dequeue the message
    NSString *message = (NSString *)[items objectAtIndex:0];
    [items removeObjectAtIndex:0];

    // Speak the message
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delay, queue, ^{
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    });
}

- (void)didFinishAnnouncement:(NSNotification *)dict
{
    NSString *valueSpoken = [[dict userInfo] objectForKey:UIAccessibilityAnnouncementKeyStringValue];
    NSString *wasSuccessful = [[dict userInfo] objectForKey:UIAccessibilityAnnouncementKeyWasSuccessful];
    NSLog(@"didFinishAnnouncement: %@, %@", wasSuccessful ? @"Yes" : @"No", valueSpoken);

    // Since we just finished one (doesn't matter if it was success or not) dequeue and run another
    [self dequeueAndSpeak];
    
    // Only mark non-busy when we're done speaking the last one in the queue
    if ([items count] == 0)
        busy = NO;
}

@end
