//
//  HistoryItem.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Placemark;
@class CloudSightQuery;
@class TagQuery;

#define SER_KEY_UNIQUE_NAME @"uniqueName"
#define SER_KEY_IMAGE_FILE  @"imageFile"
#define SER_KEY_THUMB_FILE  @"thumbFile"
#define SER_KEY_TITLE       @"title"
#define SER_KEY_STATUS      @"status"
#define SER_KEY_PLACEMARK   @"placemark"
#define SER_KEY_IS_FOUND    @"isFound"
#define SER_KEY_IS_FAILED   @"isFailed"


@interface HistoryItem : NSObject

@property (nonatomic, retain) NSString *uniqueName;
@property (nonatomic, retain) NSString *imageFile;
@property (nonatomic, retain) NSString *thumbFile;
@property (nonatomic, assign) int queryNumber;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *status;

@property (nonatomic, retain) Placemark *placemark;

@property (nonatomic, assign) BOOL isFound;
@property (nonatomic, assign) BOOL isFailed;

@property (nonatomic, retain) CloudSightQuery *cloudSightQuery;
@property (nonatomic, retain) TagQuery *tagQuery;

- (CGSize)thumbSizeInPixels;
- (NSString *)imageName;
- (NSString *)thumbName;
- (NSString *)shortDescription;
- (UIImage *)image;
- (UIImage *)thumbnailImage;
- (NSArray *)shareActivityItems;
- (BOOL) hasLocation;

- (id) initWithDictionary:(NSDictionary*)dict;
- (void) encodeWithDictionary:(NSMutableDictionary*)dictionary;

@end
