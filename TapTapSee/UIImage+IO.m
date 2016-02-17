//
//  UIImage+IO.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+IO.h"
#import "UIImage+Resize.h"

@implementation UIImage (IO)

+ (NSString *)uniqueName
{
    union
    {
        NSTimeInterval     ti;
        unsigned long long ull;
    } timeUnion;
    
    timeUnion.ti = [NSDate timeIntervalSinceReferenceDate];
    
    return [NSString stringWithFormat:@"%llx_photo", timeUnion.ull];
}

- (BOOL)saveAsJPEGinDirectory:(NSString *)directory withName:(NSString *)name
{
    NSString *imagePath = [directory stringByAppendingPathComponent:name];
    
    NSData *imageData = [self imageAsJPEGWithQuality:1.0];
    return [imageData writeToFile:imagePath atomically:YES];
}

- (BOOL)saveAsJPEGinDirectory:(NSString *)directory withName:(NSString *)name size:(CGSize)size
{
    UIImage *imageResized = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:size
                                         interpolationQuality:kCGInterpolationDefault];
    
    return [imageResized saveAsJPEGinDirectory:directory withName:name];
}

- (NSData *)imageAsJPEGWithQuality:(float)quality
{
    return UIImageJPEGRepresentation(self, quality);

    // Alternative method
//    NSMutableData *data = [NSMutableData data];
//    
//    // Setup the destination and type
//    CFStringRef uti = kUTTypeJPEG;
//    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, uti, 1, NULL);
//    if (!dest)
//        return nil;
//    
//    // Create an options dict for compression (etc)
//    CFMutableDictionaryRef options = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
//    if (!options) {
//        CFRelease(dest);
//        return nil;
//    }
//    
//    CFDictionaryAddValue(options, kCGImageDestinationLossyCompressionQuality, (__bridge CFNumberRef)[NSNumber numberWithFloat:quality]);
//    
//    // Write the image
//    CGImageDestinationAddImage(dest, self.CGImage, (CFDictionaryRef)options);
//    CGImageDestinationFinalize(dest);
//    
//    // Cleanup
//    CFRelease(options);
//	CFRelease(dest);
//    
//    return data;
}

- (NSString *)description
{
    NSString *orientation = @"";
    
    if (self.imageOrientation == UIImageOrientationUp)            orientation = @"UIImageOrientationUp";           else
    if (self.imageOrientation == UIImageOrientationDown)          orientation = @"UIImageOrientationDown";         else
    if (self.imageOrientation == UIImageOrientationLeft)          orientation = @"UIImageOrientationLeft";         else
    if (self.imageOrientation == UIImageOrientationRight)         orientation = @"UIImageOrientationRight";        else
    if (self.imageOrientation == UIImageOrientationUpMirrored)    orientation = @"UIImageOrientationUpMirrored";   else
    if (self.imageOrientation == UIImageOrientationDownMirrored)  orientation = @"UIImageOrientationDownMirrored"; else
    if (self.imageOrientation == UIImageOrientationLeftMirrored)  orientation = @"UIImageOrientationLeftMirrored"; else
    if (self.imageOrientation == UIImageOrientationRightMirrored) orientation = @"UIImageOrientationRightMirrored";
    
    CGSize cgImageSize = CGSizeMake(CGImageGetWidth(self.CGImage),
                                    CGImageGetHeight(self.CGImage));
    
    return [NSString stringWithFormat:@"{\n    size             = %@\n    CGImage.size     = %@\n    imageOrientation = %@\n}",
            NSStringFromCGSize(self.size),
            NSStringFromCGSize(cgImageSize),
            orientation];
}

@end
