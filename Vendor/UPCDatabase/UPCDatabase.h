//
//  UPCDatabase.h
//  Eyedentify
//
//  Created by Bradford Folkens on 1/13/13.
//  Copyright (c) 2013 ImageSearcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UPCDatabaseDelegate.h"

@interface UPCDatabase : NSObject
{
    NSURLSession *session;
}

@property (nonatomic, retain) NSString *query;
@property (nonatomic, assign) id <UPCDatabaseDelegate> delegate;

- (id)initWithQuery:(NSString *)query;
- (void)start;
+ (BOOL)canRecognizeType:(NSString *)type withCode:(NSString *)code;

@end
