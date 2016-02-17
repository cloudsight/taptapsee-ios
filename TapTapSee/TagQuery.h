//
//  TagQuery.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CloudSight/CloudSightQueryDelegate.h>
#import "TagQueryDelegate.h"

#define TAG_QUERY_WAIT      0
#define TAG_QUERY_SEND      1
#define TAG_QUERY_IDENTIFY  2
#define TAG_QUERY_DONE      3
#define TAG_QUERY_FAIL      4

@class CloudSightQuery, HistoryItem;

@interface TagQuery : NSObject <CloudSightQueryDelegate>
{
    CloudSightQuery *cloudSightQuery;
}

@property (nonatomic, assign) id <TagQueryDelegate> delegate;
@property (nonatomic, retain) HistoryItem *historyItem;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) CGPoint location;

@property (nonatomic, assign) int status;

- (id)initWithDelegate:(id)delegate
             withImage:(UIImage *)image
            atLocation:(CGPoint)location
       withHistoryItem:(HistoryItem *)historyItem;

- (void)startQuery;

@end
