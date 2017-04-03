//
//  CWTranslate.h
//  CamFind
//
//  Created by Bradford Folkens on 11/8/12.
//  Copyright (c) 2012 Net Ideas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CWTranslateDelegate.h"

static const int kCWInvalidResponseError = 1;

@interface CWTranslate : NSObject <NSURLConnectionDelegate>
{
    NSURLConnection *conn;
    NSMutableData *receivedData;
}

@property (nonatomic, retain) NSArray *availableLanguages;
@property (nonatomic, assign) id<CWTranslateDelegate> delegate;

+ (NSString *)currentLanguageIdentifier;
+ (NSString *)translate:(NSString *)string withSourceLanguage:(NSString *)sourceLanguageIdentifier withDestinationLanguage:(NSString *)destinationLanguageIdentifier;
+ (NSArray *)availableLanguages:(NSString *)destinationLanguageIdentifier;
- (void)asyncRetrieveAvailableLanguages:(NSString *)destinationLanguageIdentifier;

@end
