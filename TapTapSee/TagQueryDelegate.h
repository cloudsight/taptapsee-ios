//
//  TagQueryDelegate.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HistoryItem;
@class TagQuery;

@protocol TagQueryDelegate <NSObject>

- (void)didUploadItem:(HistoryItem *)item withQuery:(TagQuery *)query;
- (void)didIdentifyItem:(HistoryItem *)item withQuery:(TagQuery *)query;
- (void)didDequeueItem:(HistoryItem *)item withQuery:(TagQuery *)query;
- (void)didFailItem:(HistoryItem *)item withQuery:(TagQuery *)query;

@end
