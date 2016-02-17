//
//  BarcodeContentDetector.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "BarcodeContentDetector.h"
#import "HistoryItemStore.h"
#import "UPCDatabase.h"
#import "ISBNDatabase.h"

@implementation BarcodeContentDetector

- (id)initWithDelegate:(id)delegate withFeatureType:(NSString *)type withFeatureDescription:(NSString *)description
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        featureType = type;
        featureDescription = description;
    }
    
    return self;
}

- (void)start
{
    // Check to see if it's a URL
    NSString *urlFromData = [self extractUrl:featureDescription];
    if (urlFromData != nil) {
        // TODO: mark as a URL so we can do a webview
    }
    
    // If it begins with 978 and it's an EAN-13 it might be an ISBN encoded as an EAN-13
    if ([ISBNDatabase canRecognizeType:featureType withCode:featureDescription]) {
        ISBNDatabase *isbnDB = [[ISBNDatabase alloc] initWithQuery:featureDescription];
        [isbnDB setDelegate:self];
        [isbnDB start];
    } else if ([UPCDatabase canRecognizeType:featureType withCode:featureDescription]) {
        UPCDatabase *upcDB = [[UPCDatabase alloc] initWithQuery:featureDescription];
        [upcDB setDelegate:self];
        [upcDB start];
    } else {
        [[self delegate] barcodeContentDetector:self didIdentifyWithString:featureDescription];
    }
}

- (NSString *)extractUrl:(NSString *)candidate
{
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            return [url absoluteString];
        }
    }
    
    return nil;
}

# pragma mark UPCDatabase delegate

- (void)upcDatabase:(UPCDatabase *)db didFindProduct:(NSString *)name
{
    [[self delegate] barcodeContentDetector:self didIdentifyWithString:name];
}

- (void)upcDatabase:(UPCDatabase *)db didFinishWithError:(NSError *)error
{
    // Ignore error and return default response (upc)
    [[self delegate] barcodeContentDetector:self didIdentifyWithString:featureDescription];
}

# pragma mark ISBNDatabase delegate

- (void)isbnDatabase:(ISBNDatabase *)db didFindProduct:(NSString *)name
{
    [[self delegate] barcodeContentDetector:self didIdentifyWithString:name];
}

- (void)isbnDatabase:(ISBNDatabase *)db didFinishWithError:(NSError *)error
{
    // Ignore error and return default response (upc)
    [[self delegate] barcodeContentDetector:self didIdentifyWithString:featureDescription];
}

@end
