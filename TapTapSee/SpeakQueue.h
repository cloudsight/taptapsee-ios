//
//  SpeakQueue.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeakQueue : NSObject
{
    NSMutableArray *items;
    BOOL busy;
}

+ (SpeakQueue *)sharedQueue;
- (void)speak:(NSString *)message;
- (BOOL)isBusy;

@end
