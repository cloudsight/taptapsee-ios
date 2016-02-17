//
//  HistoryItemStore.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CloudSight/CloudSightQuery.h>
#import "HistoryItem.h"

#define STR_KEY_HISTORY @"history"


@interface HistoryItemStore : NSObject
{
    NSMutableArray *items;
}

+ (HistoryItemStore *)sharedStore;
+ (UIImage *)imageForFilename:(NSString *)thumbFile;
+ (NSString *)fullPathForImageFilename:(NSString *)name;
+ (NSString *)documentPath;
+ (NSString *)itemArchivePath;

- (void)removeItemAtIndex:(int)index;
- (void)removeItem:(HistoryItem *)item;
- (void)removeUnfinishedQueries;

- (HistoryItem *)createItemForImage:(UIImage *)image;
- (HistoryItem *)createItemForText:(NSString *)text;

- (HistoryItem *)itemForCloudSightQuery:(CloudSightQuery *)query;
- (HistoryItem *)itemForTitle:(NSString *)title;

- (NSArray *)items;
- (BOOL)saveChanges;

@end
