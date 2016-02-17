//
//  UIImage+FitToRange.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FitToRange)

- (UIImage*)fitToRangeFrom:(NSUInteger)maxDimension1 to:(NSUInteger)maxDimension2;

@end
