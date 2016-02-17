//
//  Placemark.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SER_KEY_LATITUDE            @"latitude"
#define SER_KEY_LONGITUDE           @"longitude"
#define SER_KEY_COORDINATE_ACCURACY @"coordinateAccuracy"
#define SER_KEY_ALTITUDE            @"altitude"
#define SER_KEY_ALTITUDE_ACCURACY   @"altitudeAccuracy"
#define SER_KEY_HEADING             @"heading"
#define SER_KEY_HEADING_ACCURACY    @"headingAccuracy"


@interface Placemark : NSObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double coordinateAccuracy;

@property (nonatomic, assign) double altitude;
@property (nonatomic, assign) double altitudeAccuracy;

@property (nonatomic, assign) double heading;
@property (nonatomic, assign) double headingAccuracy;

- (NSString *)toQueryStringValue;
- (NSString *)coordinatesAsISO6709String;
- (CLLocation *)toCLLocation;

- (id) initWithDictionary:(NSDictionary*)dict;
- (void) encodeWithDictionary:(NSMutableDictionary*)dict;

@end
