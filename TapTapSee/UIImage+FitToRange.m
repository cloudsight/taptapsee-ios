//
//  UIImage+FitToRange.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "UIImage+FitToRange.h"

@implementation UIImage (FitToRange)

- (UIImage*)fitToRangeFrom:(NSUInteger)maxDimension1 to:(NSUInteger)maxDimension2
{
    CGSize inputSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    
    // Determine max size.
    int biggerMaxDimension  = (maxDimension1 > maxDimension2) ? maxDimension1 : maxDimension2;
    int smallerMaxDimension = (maxDimension1 > maxDimension2) ? maxDimension2 : maxDimension1;
    
    CGSize maxSize;
    if (inputSize.width > inputSize.height)
        maxSize = CGSizeMake(biggerMaxDimension, smallerMaxDimension);
    else
        maxSize = CGSizeMake(smallerMaxDimension, biggerMaxDimension);
    
    // Determine final size.
    CGSize finalSize = inputSize;
    if ((finalSize.width > maxSize.width) || (finalSize.height > maxSize.height))
    {
        if (finalSize.width > maxSize.width)
        {
            CGSize oldSize   = finalSize;
            finalSize.width  = maxSize.width;
            finalSize.height = (finalSize.width * oldSize.height) / oldSize.width;
        }
        
        if (finalSize.height > maxSize.height)
        {
            CGSize oldSize   = finalSize;
            finalSize.height = maxSize.height;
            finalSize.width  = (finalSize.height * oldSize.width) / oldSize.height;
        }
        
        finalSize.width  = ceilf(finalSize.width);
        finalSize.height = ceilf(finalSize.height);
    }
    
    // Make scaled image.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 finalSize.width,
                                                 finalSize.height,
                                                 8,
                                                 4 * ((int)finalSize.width),
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpace);
    
    CGRect outputRect = CGRectZero;
    outputRect.size   = finalSize;
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, outputRect, self.CGImage);
    
    CGImageRef outputCGImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage* output = [UIImage imageWithCGImage:outputCGImage
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(outputCGImage);
    
    return output;
}

@end
