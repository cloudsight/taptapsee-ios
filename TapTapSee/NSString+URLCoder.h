//
//  NSString+URLCoder.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLCoder)

- (NSString *)urlEncode;
- (NSString *)urlDecode;

@end
