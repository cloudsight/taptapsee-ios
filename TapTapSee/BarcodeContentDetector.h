//
//  BarcodeContentDetector.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

#import "BarcodeContentDetectorDelegate.h"
#import "UPCDatabaseDelegate.h"
#import "ISBNDatabaseDelegate.h"

@interface BarcodeContentDetector : NSObject <UPCDatabaseDelegate, ISBNDatabaseDelegate>
{
    NSString *featureDescription;
    NSString *featureType;
}

@property (nonatomic, assign) id <BarcodeContentDetectorDelegate> delegate;

- (id)initWithDelegate:(id)delegate withFeatureType:(NSString *)type withFeatureDescription:(NSString *)description;
- (void)start;

@end
