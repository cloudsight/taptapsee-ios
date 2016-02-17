//
//  TagQuery.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <CloudSight/CloudSightQuery.h>

#import "TagQuery.h"
#import "TagQueryDelegate.h"
#import "Placemark.h"
#import "HistoryItem.h"
#import "HistoryItemStore.h"
#import "Config.h"
#import "Reachability.h"
#import "UIImage+FitToRange.h"
#import "UIImage+IO.h"

#define WWAN_QUALITY 0.4
#define WIFI_QUALITY 0.7


@implementation TagQuery

- (id)initWithDelegate:(id)delegate
             withImage:(UIImage *)image
            atLocation:(CGPoint)location
       withHistoryItem:(HistoryItem *)historyItem
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _image = image;
        _location = location;
        _historyItem = historyItem;
    }
    
    return self;
}

- (void)dealloc
{
    DDLogDebug(@"dealloc");
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"status: %d, historyItem: %@", _status, _historyItem];
}

- (void)startQuery
{
    NSData *imageData;

    // Change to a smaller image if we're using WWAN instead of WiFi
    if ([[TMReachability reachabilityForInternetConnection] isReachableViaWiFi])
        imageData = [self.image imageAsJPEGWithQuality:WIFI_QUALITY];
    else
        imageData = [self.image imageAsJPEGWithQuality:WWAN_QUALITY];

    // Start CloudSight
    cloudSightQuery = [[CloudSightQuery alloc] initWithImage:imageData
                                                  atLocation:_location
                                                withDelegate:self
                                                 atPlacemark:[[_historyItem placemark] toCLLocation]
                                                withDeviceId:@""];
    
    [cloudSightQuery start];
    [_historyItem setCloudSightQuery:cloudSightQuery];
}

- (void)cancel
{
    [cloudSightQuery stop];
}

- (void)didFailWithMessage:(NSString *)error
{
    _historyItem.status = error;
    _historyItem.isFailed = YES;
    
    [self.delegate didFailItem:_historyItem withQuery:self];
}

# pragma mark CloudSightQuery delegate implementation

- (void)cloudSightQueryDidFinishIdentifying:(CloudSightQuery *)query
{
    DDLogDebug(@"cloudSightQueryDidFinishIdentifying: %@", query);
    
    if (_historyItem != nil && !_historyItem.isFound) {
        _historyItem.title = _historyItem.cloudSightQuery.name;
        _historyItem.isFound = YES;
        
        [self.delegate didIdentifyItem:_historyItem withQuery:self];
    }
}

- (void)cloudSightQueryDidFinishUploading:(CloudSightQuery *)query
{
    DDLogDebug(@"cloudSightQueryDidFinishUploading: %@", query);
    
    if (_historyItem != nil && !_historyItem.isFound) {
        _historyItem.status = @"Identifying...";
        
        [self.delegate didUploadItem:_historyItem withQuery:self];
    }
}

- (void)cloudSightQueryDidFail:(CloudSightQuery *)query withError:(NSError *)error
{
    DDLogDebug(@"cloudSightQueryDidFail: %@", error);

    [self didFailWithMessage:[error localizedDescription]];
}

- (void)cloudSightQueryDidUpdateTag:(CloudSightQuery *)query
{
    DDLogDebug(@"cloudSightDidUpdateTag: %@", query);
}

@end
