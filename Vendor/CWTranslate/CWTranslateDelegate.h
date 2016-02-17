//
//  CWTranslateDelegate.h
//  Eyedentify
//
//  Created by Bradford Folkens on 12/11/12.
//  Copyright (c) 2012 ImageSearcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CWTranslate;

@protocol CWTranslateDelegate <NSObject>

- (void)translate:(CWTranslate *)translate didReceiveLanguages:(NSArray *)languages;
- (void)translate:(CWTranslate *)translate didFailToReceiveLanguagesWithError:(NSError *)error;

@end
