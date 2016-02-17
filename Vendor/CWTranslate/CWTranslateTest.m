//
//  CWTranslateTest.m
//  CamFind
//
//  Created by Bradford Folkens on 6/23/14.
//  Copyright (c) 2014 Image Searcher Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "XCTestCase+Fixtures.h"
#import "CWTranslate.h"

@interface CWTranslate(PrivateMethods)

+ (NSArray *)parseLanguagesResponse:(NSData *)responseBody;
+ (NSString *)parseTranslationResponse:(NSString *)responseBody;

@end

@interface CWTranslateTest : XCTestCase
{
    CWTranslate *translate;
}
@end

@implementation CWTranslateTest

- (void)setUp
{
    [super setUp];
    
    translate = [[CWTranslate alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testShouldGetCurrentlLanguageIdentifier
{
    XCTAssertNotNil([CWTranslate currentLanguageIdentifier], @"Current language identifier should not be nil");
}

- (void)testShouldRetrieveAvailableLanguages
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"www.googleapis.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"languages_response.json", nil)
                                                statusCode:200 headers:@{ @"Content-Type" : @"text/json" }];
    }];
    
    NSArray *languages = [CWTranslate availableLanguages:@"en"];
    
    XCTAssertNotNil(languages, @"Language list should not be nil");
    XCTAssert([languages count] > 0, @"Language list should be populated");
}

- (void)testShouldParseLanguagesResponse
{
    NSData *data = [self loadFixture:@"languages_response.json"];
    NSArray *languages = [CWTranslate parseLanguagesResponse:data];
    
    XCTAssertNotNil(languages, @"Language list should not be nil");
    XCTAssert([languages count] == 81, @"Language list should be populated");
}

- (void)testShouldParseTranslationResponse
{
    NSString *data = [self loadFixtureAsUTF8String:@"translation_response.json"];
    NSString *translatedText = [CWTranslate parseTranslationResponse:data];
    
    XCTAssertEqualObjects(@"Hallo Welt", translatedText, @"Should parse response into translated text");
}

@end
