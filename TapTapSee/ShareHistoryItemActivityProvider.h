//
//  ShareHistoryItemActivityProvider.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryItem.h"

@interface ShareHistoryItemActivityProvider : UIActivityItemProvider
{
    HistoryItem *historyItem;
}

- (id)initWithHistoryItem:(HistoryItem *)item;

@end
