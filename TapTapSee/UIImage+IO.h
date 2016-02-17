//
//  UIImage+IO.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IO)

+ (NSString *)uniqueName;
- (BOOL)saveAsJPEGinDirectory:(NSString *)directory withName:(NSString *)name;
- (BOOL)saveAsJPEGinDirectory:(NSString *)directory withName:(NSString *)name size:(CGSize)size;
- (NSData *)imageAsJPEGWithQuality:(float)quality;
- (NSString *)description;

@end
