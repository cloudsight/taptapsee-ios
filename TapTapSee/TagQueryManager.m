//
//  TagQueryManager.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "TagQueryManager.h"
#import "TagQuery.h"
#import "HistoryItem.h"
#import "Reachability.h"

#define MAX_SIMULTANEOUS_SEND_ON_WWAN 1
#define MAX_SIMULTANEOUS_SEND_ON_WIFI 3

@implementation TagQueryManager

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)init
{
    self = [super init];
    if (self) {
        queries = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

+ (TagQueryManager *)sharedManager
{
    static TagQueryManager *sharedManager = nil;
    if (!sharedManager) {
        // Skip over alloc override below
        sharedManager = [[super allocWithZone:nil] init];
    }
    
    return sharedManager;
}

- (void)dealloc
{
    NSLog(@"TagQueryManager got dealloc'ed");

    [self stopPeriodicReassessTimer];
}

- (TagQuery *)queryWithImage:(UIImage *)image withFocus:(CGPoint)location withHistoryItem:(HistoryItem *)historyItem
{
    TagQuery *query = [[TagQuery alloc] initWithDelegate:self
                                               withImage:image
                                              atLocation:location
                                         withHistoryItem:historyItem];
    
    query.status = TAG_QUERY_WAIT;
    [queries addObject:query];
    
    [self startPeriodicReassessTimer];
    
    return query;
}

- (void)reset
{
    [queries removeAllObjects];
}

- (int)busyCount
{
    return busyCount;
}

- (TagQuery *)tagQueryForItem:(HistoryItem *)item
{
    for (TagQuery *query in queries) {
        if ([query historyItem] == item)
            return query;
    }
    
    return nil;
}

- (void)restartItem:(HistoryItem *)item
{
    TagQuery *query = [self tagQueryForItem:item];
    query.status = TAG_QUERY_WAIT;
    
    [self startPeriodicReassessTimer];
}

- (void)startPeriodicReassessTimer
{
    // Check if we're already running
    if (periodicReassessTimer != nil)
        return;
    
    periodicReassessTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(reassessQueryQueue)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)stopPeriodicReassessTimer
{
    // Check if we're already stopped
    if (periodicReassessTimer == nil)
        return;

    [periodicReassessTimer invalidate];
    periodicReassessTimer = nil;
}

- (void)reassessQueryQueue
{
    int waiting = 0;
    int sending = 0;
    int identifying = 0;
    int done = 0;
    int failed = 0;
    
    for (TagQuery *query in queries) {
        if (query.status == TAG_QUERY_WAIT)
            waiting += 1;
        
        if (query.status == TAG_QUERY_SEND)
            sending += 1;
        
        if (query.status == TAG_QUERY_IDENTIFY)
            identifying += 1;

        if (query.status == TAG_QUERY_DONE)
            done += 1;

        if (query.status == TAG_QUERY_FAIL)
            failed += 1;
    }
    
    busyCount = waiting + sending + identifying;
    
    // Check to see if we're idle and stop the periodic timer
    if (busyCount < 1)
        [self stopPeriodicReassessTimer];
    
    // Dequeue and start as long as the queue counts make sense
    TMReachability *reachability = [TMReachability reachabilityForInternetConnection];
    int max_simultaneous_send = [reachability isReachableViaWiFi] ? MAX_SIMULTANEOUS_SEND_ON_WIFI : MAX_SIMULTANEOUS_SEND_ON_WWAN;
    NSLog(@"TagQueryManager (max send %d): WAIT: %d, SEND: %d, IDENTIFY: %d, DONE: %d, FAIL: %d", max_simultaneous_send, waiting, sending, identifying, done, failed);
    
    if (waiting > 0 && sending < max_simultaneous_send) {
        // Find the first waiting query
        for (TagQuery *query in queries) {
            if (query.status == TAG_QUERY_WAIT) {
                // Mark this one as sending (and send)
                query.status = TAG_QUERY_SEND;
                [query startQuery];
                
                // Notify upstream
                [self didDequeueItem:[query historyItem] withQuery:query];

                return;
            }
        }
    }
}

#pragma mark TagQuery implementation

- (void)didUploadItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    query.status = TAG_QUERY_IDENTIFY;
    
    if ([self delegate]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] didUploadItem:item withQuery:query];
        });
    }

    [self reassessQueryQueue];
}

- (void)didIdentifyItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    query.status = TAG_QUERY_DONE;

    if ([self delegate]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] didIdentifyItem:item withQuery:query];
        });
    }
}

- (void)didDequeueItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    [item setStatus:@"Sending image..."];

    if ([self delegate]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] didDequeueItem:item withQuery:query];
        });
    }
}

- (void)didFailItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    query.status = TAG_QUERY_FAIL;
    
    if ([self delegate]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] didFailItem:item withQuery:query];
        });
    }
}

@end
