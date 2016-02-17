//
//  Placemark.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "Placemark.h"

@implementation Placemark

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f) @%f, alt:%f @%f, heading:%f @%f", [self latitude], [self longitude], [self coordinateAccuracy], [self altitude], [self altitudeAccuracy], [self heading], [self headingAccuracy]];
}

- (NSString *)toQueryStringValue
{
    return [NSString stringWithFormat:@"%f,%f,%f,%f,%f", [self latitude], [self longitude], [self coordinateAccuracy], [self altitude], [self altitudeAccuracy]];
}

- (NSString *)coordinatesAsISO6709String
{
    NSNumberFormatter *latFormatter = [[NSNumberFormatter alloc] init];
    [latFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [latFormatter setPositivePrefix:@"+"];
    [latFormatter setMinimumIntegerDigits:2];
    [latFormatter setMinimumFractionDigits:5];
    
    NSNumberFormatter *lngFormatter = [[NSNumberFormatter alloc] init];
    [lngFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [lngFormatter setPositivePrefix:@"+"];
    [lngFormatter setMinimumIntegerDigits:3];
    [lngFormatter setMinimumFractionDigits:5];
    
    NSString *formattedStr = [NSString stringWithFormat:@"%@%@/",
                              [latFormatter stringFromNumber:[NSNumber numberWithDouble:self.latitude]],
                              [lngFormatter stringFromNumber:[NSNumber numberWithDouble:self.longitude]]];
    
    return formattedStr;
}

- (CLLocation *)toCLLocation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:self.altitude
                                               horizontalAccuracy:self.coordinateAccuracy
                                                 verticalAccuracy:self.coordinateAccuracy
                                                        timestamp:[[NSDate alloc] initWithTimeIntervalSinceNow:0]];
    
    return location;
}

#pragma mark Serialization

- (id) initWithDictionary:(NSDictionary*)dict
{
    self = [self init];
    if (self)
    {
        _latitude           = [[dict objectForKey:SER_KEY_LATITUDE] doubleValue];
        _longitude          = [[dict objectForKey:SER_KEY_LONGITUDE] doubleValue];
        _coordinateAccuracy = [[dict objectForKey:SER_KEY_COORDINATE_ACCURACY] doubleValue];
        _altitude           = [[dict objectForKey:SER_KEY_ALTITUDE] doubleValue];
        _altitudeAccuracy   = [[dict objectForKey:SER_KEY_ALTITUDE_ACCURACY] doubleValue];
        _heading            = [[dict objectForKey:SER_KEY_HEADING] doubleValue];
        _headingAccuracy    = [[dict objectForKey:SER_KEY_HEADING_ACCURACY] doubleValue];
    }
    return self;
}

- (void) encodeWithDictionary:(NSMutableDictionary*)dict
{
    [dict setObject:[NSNumber numberWithDouble:_latitude]            forKey:SER_KEY_LATITUDE];
    [dict setObject:[NSNumber numberWithDouble:_longitude]           forKey:SER_KEY_LONGITUDE];
    [dict setObject:[NSNumber numberWithDouble:_coordinateAccuracy]  forKey:SER_KEY_COORDINATE_ACCURACY];
    [dict setObject:[NSNumber numberWithDouble:_altitude]            forKey:SER_KEY_ALTITUDE];
    [dict setObject:[NSNumber numberWithDouble:_altitudeAccuracy]    forKey:SER_KEY_ALTITUDE_ACCURACY];
    [dict setObject:[NSNumber numberWithDouble:_heading]             forKey:SER_KEY_HEADING];
    [dict setObject:[NSNumber numberWithDouble:_headingAccuracy]     forKey:SER_KEY_HEADING_ACCURACY];
}

@end
