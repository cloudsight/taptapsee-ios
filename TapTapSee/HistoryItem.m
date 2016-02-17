//
//  HistoryItem.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "HistoryItem.h"
#import "Config.h"
#import "Placemark.h"
#import "HistoryItemStore.h"
#import "ShareHistoryItemActivityProvider.h"
#import "UIImage+IO.h"

@implementation HistoryItem

- (id)init
{
    self = [super init];
    if (self) {
        self.uniqueName = [UIImage uniqueName];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id:'%@', status:'%@', image:'%@', thumb:'%@', placemark: '%@'", self.uniqueName, self.status, self.imageFile, self.thumbFile, self.placemark];
}

- (NSString *)shortDescription
{
    if ([self isFound]) {
        return [self title];
    }
    
    return [self status];
}

- (UIImage *)image
{
    return [HistoryItemStore imageForFilename:[self imageFile]];
}

- (UIImage *)thumbnailImage
{
    return [HistoryItemStore imageForFilename:[self thumbFile]];
}

- (NSString *)imageName
{
    return [NSString stringWithFormat:@"%@.jpg", [self uniqueName]];
}

- (NSString *)thumbName
{
    return [NSString stringWithFormat:@"%@thumb.jpg", [self uniqueName]];
}

- (NSArray *)shareActivityItems
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    
    ShareHistoryItemActivityProvider *shareActivityProvider = [[ShareHistoryItemActivityProvider alloc] initWithHistoryItem:self];
    [items addObject:shareActivityProvider];
    
    if ([self image] != nil)
        [items addObject:[self image]];
    
    return items;
}

- (BOOL)hasLocation
{
    return ([self placemark] != nil);
}

- (CGSize)thumbSizeInPixels
{
    CGFloat screenScale = 1.0;
    
    // Retina display.
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)])
        screenScale = [UIScreen mainScreen].scale;
    
    return CGSizeMake(THUMB_WIDTH * screenScale, THUMB_HEIGHT * screenScale);
}

#pragma mark Serialization

- (id) initWithDictionary:(NSDictionary*)dict
{
    self = [self init];
    if (self)
    {
        _uniqueName = [dict objectForKey:SER_KEY_UNIQUE_NAME];
        _imageFile  = [dict objectForKey:SER_KEY_IMAGE_FILE];
        _thumbFile  = [dict objectForKey:SER_KEY_THUMB_FILE];
        
        _title      = [dict objectForKey:SER_KEY_TITLE];
        _status     = [dict objectForKey:SER_KEY_STATUS];
        
        _isFound    = [dict objectForKey:SER_KEY_IS_FOUND] ? YES : NO;
        _isFailed   = [dict objectForKey:SER_KEY_IS_FAILED] ? YES : NO;
        
        NSDictionary *placemarkDict = [dict objectForKey:SER_KEY_PLACEMARK];
        _placemark = [[Placemark alloc] initWithDictionary:placemarkDict];
    }
    return self;
}

- (void) encodeWithDictionary:(NSMutableDictionary*)dict
{
    if (_uniqueName)  [dict setObject:_uniqueName  forKey:SER_KEY_UNIQUE_NAME];
    if (_imageFile)   [dict setObject:_imageFile   forKey:SER_KEY_IMAGE_FILE];
    if (_thumbFile)   [dict setObject:_thumbFile   forKey:SER_KEY_THUMB_FILE];
    
    if (_title)       [dict setObject:_title       forKey:SER_KEY_TITLE];
    if (_status)      [dict setObject:_status      forKey:SER_KEY_STATUS];
    
    if (_isFound)     [dict setObject:[NSNumber numberWithBool:_isFound] forKey:SER_KEY_IS_FOUND];
    if (_isFailed)    [dict setObject:[NSNumber numberWithBool:_isFailed] forKey:SER_KEY_IS_FAILED];
    
    if (self.placemark) {
        NSMutableDictionary *placemarkDict = [[NSMutableDictionary alloc] init];
        [self.placemark encodeWithDictionary:placemarkDict];
        [dict setObject:placemarkDict forKey:SER_KEY_PLACEMARK];
    }
}

@end
