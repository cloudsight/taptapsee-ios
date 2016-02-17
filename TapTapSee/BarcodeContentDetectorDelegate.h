//
//  BarcodeContentDetectorDelegate.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BarcodeContentDetectorDelegate <NSObject>

- (void)barcodeContentDetector:(id)sender didIdentifyWithString:(NSString *)item;

@end
