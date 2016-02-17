//
//  CWTranslate.m
//  CamFind
//
//  Created by Bradford Folkens on 11/8/12.
//  Copyright (c) 2012 Net Ideas. All rights reserved.
//

#import "CWTranslate.h"
#import "NSString+URLCoder.h"


@interface CWTranslate()

+ (NSArray *)parseLanguagesResponse:(NSData *)responseBody;
+ (NSString *)parseTranslationResponse:(NSString *)responseBody;

@end


@implementation CWTranslate

+ (NSString *)currentLanguageIdentifier
{
    static NSString* currentLanguage = nil;

    if (currentLanguage == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
        currentLanguage = [languages objectAtIndex:0];
    }
    
    // Ignore chinese for now
    if ([currentLanguage isEqualToString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hant"])
        currentLanguage = @"en";

    return currentLanguage;
}

+ (NSString *)translate:(NSString *)string withSourceLanguage:(NSString *)sourceLanguageIdentifier withDestinationLanguage:(NSString *)destinationLanguageIdentifier
{
    static NSString* queryURL = @"https://www.googleapis.com/language/translate/v2?key=%@&q=%@&source=%@&target=%@";

    if (sourceLanguageIdentifier == nil)
        sourceLanguageIdentifier = @"en";
    
    if (destinationLanguageIdentifier == nil)
        destinationLanguageIdentifier = [CWTranslate currentLanguageIdentifier];

    if ([sourceLanguageIdentifier isEqualToString:destinationLanguageIdentifier] || string == nil)
        return string;

    NSString* escapedString = [[string lowercaseStringWithLocale:[NSLocale currentLocale]] urlEncode];
    NSString* query = [NSString stringWithFormat:queryURL,
                       GOOGLE_API_KEY, escapedString, sourceLanguageIdentifier, destinationLanguageIdentifier];

    NSString* response = [NSString stringWithContentsOfURL:[NSURL URLWithString:query]
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    if (response == nil)
        return string;

    NSString *translatedString = [CWTranslate parseTranslationResponse:response];
    if (translatedString == nil)
        return string;

    return translatedString;
}

+ (NSArray *)availableLanguages:(NSString *)destinationLanguageIdentifier
{
    if (destinationLanguageIdentifier == nil)
        destinationLanguageIdentifier = [CWTranslate currentLanguageIdentifier];
    
    static NSString* queryURL = @"https://www.googleapis.com/language/translate/v2/languages?key=%@&prettyprint=false&target=%@";

    NSString* query = [NSString stringWithFormat:queryURL, GOOGLE_API_KEY, destinationLanguageIdentifier];
    NSData* response = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
    
    if (response == nil)
        return nil;
    
    return [CWTranslate parseLanguagesResponse:response];
}

- (void)asyncRetrieveAvailableLanguages:(NSString *)destinationLanguageIdentifier
{
    if (destinationLanguageIdentifier == nil)
        destinationLanguageIdentifier = [CWTranslate currentLanguageIdentifier];
    
    static NSString *queryURL = @"https://www.googleapis.com/language/translate/v2/languages?key=%@&prettyprint=false&target=%@";

    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:queryURL, GOOGLE_API_KEY, destinationLanguageIdentifier]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:15.0];

    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];  // make sure delegates get called
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    DDLogDebug(@"CWTranslate:connection:didReceiveResponse:%@", (NSHTTPURLResponse*)response);
    
    if ([(NSHTTPURLResponse *)response statusCode] != 200)
        [self.delegate translate:self didFailToReceiveLanguagesWithError:[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                                                             code:kCWInvalidResponseError
                                                                                         userInfo:@{NSLocalizedDescriptionKey : @"Invalid Response"}]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DDLogDebug(@"CWTranslate:connection:didReceiveData");
    if (!receivedData)
        receivedData = [[NSMutableData alloc] init];
    
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DDLogDebug(@"CWTranslate:connectionDidFinishLoading");
    self.availableLanguages = [CWTranslate parseLanguagesResponse:receivedData];
    
    [self.delegate translate:self didReceiveLanguages:self.availableLanguages];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DDLogDebug(@"CWTranslate:connection:didFailWithError %@", error);
    
    [self.delegate translate:self didFailToReceiveLanguagesWithError:error];
}

- (void)dealloc
{
    DDLogDebug(@"CWTranslate got dealloc'ed");
    [conn cancel];
}

#pragma mark Private methods

+ (NSArray *)parseLanguagesResponse:(NSData *)data
{
    NSError *error;
    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || obj == nil) {
        DDLogDebug(@"Error reading languages: %@", error);
        return nil;
    }

    NSMutableArray *languages = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *languageItem in [obj valueForKeyPath:@"data.languages"])
        [languages addObject:languageItem];
    
    return languages;
}

+ (NSString *)parseTranslationResponse:(NSString *)responseBody
{
    NSScanner* scanner = [NSScanner scannerWithString:responseBody];
    
    if (![scanner scanUpToString:@"\"translatedText\": \"" intoString:NULL])
        return nil;
    
    if (![scanner scanString:@"\"translatedText\": \"" intoString:NULL])
        return nil;
    
    NSString* result = nil;
    if (![scanner scanUpToString:@"\"" intoString:&result])
        return nil;
    
    return result;
}


@end
