//
//  TagQueryManager.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagQueryDelegate.h"

@interface TagQueryManager : NSObject <TagQueryDelegate>
{
    NSMutableArray *queries;
    NSTimer *periodicReassessTimer;
    int busyCount;
}

@property (nonatomic, assign) id <TagQueryDelegate> delegate;

+ (TagQueryManager *)sharedManager;
- (TagQuery *)queryWithImage:(UIImage *)image withFocus:(CGPoint)location withHistoryItem:(HistoryItem *)historyItem;
- (void)reset;
- (int)busyCount;
- (void)restartItem:(HistoryItem *)item;
- (TagQuery *)tagQueryForItem:(HistoryItem *)item;

@end
