//
//  ShareHistoryItemActivityProvider.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareHistoryItemActivityProvider.h"

@implementation ShareHistoryItemActivityProvider

- (id)initWithHistoryItem:(HistoryItem *)item
{
    self = [super initWithPlaceholderItem:@""];
    if (self) {
        historyItem = item;
    }
    
    return self;
}

- (id)item
{
    DebugLog(@"activityType = %@", self.activityType);
    
    if (self.activityType == UIActivityTypeMail)
        return [NSString stringWithFormat:NSLocalizedString(@"I discovered this was a '%@' with TapTapSee.  Download on iTunes: %@", @""), [historyItem title], @"http://goo.gl/QzFA1i"];
    else if (self.activityType == UIActivityTypePostToTwitter)
        return [NSString stringWithFormat:NSLocalizedString(@"I discovered this was a '%@' - @TapTapSee %@", @""), [historyItem title], @"http://goo.gl/jZF2FG"];
    else if (self.activityType == UIActivityTypePostToFacebook)
        return [NSString stringWithFormat:NSLocalizedString(@"I discovered this was a '%@' with TapTapSee.  Download on iTunes: %@", @""), [historyItem title], @"http://goo.gl/9l3JH4"];
    else if (self.activityType == UIActivityTypeMessage)
        return [NSString stringWithFormat:NSLocalizedString(@"I discovered this was a '%@' with TapTapSee.  Download on iTunes: %@", @""), [historyItem title], @"http://goo.gl/5T6Wsu"];
    else if (self.activityType == UIActivityTypeSaveToCameraRoll) {
        NSMutableDictionary *tiffMetadata = [[NSMutableDictionary alloc] init];
        [tiffMetadata setObject:[historyItem title] forKey:(NSString *)kCGImagePropertyTIFFImageDescription];

        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
        [metadata setObject:tiffMetadata forKey:(NSString*)kCGImagePropertyTIFFDictionary];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[[historyItem image] CGImage]
                                         metadata:metadata
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error)
                DebugLog(@"errors: %@", error);
            else
                DebugLog(@"write finished: %@", assetURL);
        }];
        
        return nil;
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"I discovered this was a '%@' with TapTapSee.  Download on iTunes: %@", @""), [historyItem title]];
}

@end
