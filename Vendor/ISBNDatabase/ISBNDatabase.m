//
//  ISBNDatabase.m
//  Eyedentify
//
//  Created by Bradford Folkens on 1/13/13.
//  Copyright (c) 2013 ImageSearcher. All rights reserved.
//

#import "ISBNDatabase.h"
#import "GTMNSString+HTML.h"

@implementation ISBNDatabase

- (id)initWithQuery:(NSString *)query
{
    self = [super init];
    if (self) {
        self.query = query;
    }
    
    return self;
}

+ (BOOL)canRecognizeType:(NSString *)type withCode:(NSString *)code
{
    return ([code rangeOfString:@"978"].location != NSNotFound &&
            ([type isEqualToString:AVMetadataObjectTypeEAN13Code] || [type isEqualToString:AVMetadataObjectTypeEAN8Code]));
}

- (void)start
{
    NSString *queryUrl = [NSString stringWithFormat:@"http://isbndb.com/api/books.xml?access_key=F4L2QJ3Y&index1=isbn&value1=%@", [self query]];

    // Setup connection session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:30];
    
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryUrl]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data == nil) {
            // Ignore
            return;
        }
        
        NSString *doc = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *productName = [self scanForProductName:doc];

        // Return the product
        if (productName)
            [self.delegate isbnDatabase:self didFindProduct:productName];
        else
            [self.delegate isbnDatabase:self didFinishWithError:nil];
    }];

    [task resume];
    [session finishTasksAndInvalidate];
}

- (void)dealloc
{
    [session invalidateAndCancel];
}

- (NSString *)scanForProductName:(NSString *)doc
{
    NSError *error = nil;
    NSRegularExpression *descriptionPattern = [[NSRegularExpression alloc] initWithPattern:@"<Title>(.+?)</Title>" options:0 error:&error];
    
    // Check for a match
    NSTextCheckingResult *match = [descriptionPattern firstMatchInString:doc options:0 range:NSMakeRange(0, [doc length])];
    if (match) {
        // Product name will be in capture group 1
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *matchString = [[doc substringWithRange:matchRange] gtm_stringByUnescapingFromHTML];
        
        // Sanity check the product name and return
        if (matchString != nil && [matchString length] > 0)
            return matchString;
    }
    
    return nil;
}

@end
