//
//  HistoryItemStore.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "HistoryItemStore.h"
#import "Config.h"
#import "UIImage+IO.h"

#define MAX_ITEMS   5


@implementation HistoryItemStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
        items = [NSMutableArray arrayWithCapacity:MAX_ITEMS];
    }
    
    return self;
}

+ (HistoryItemStore *)sharedStore
{
    static HistoryItemStore *sharedStore = nil;
    if (!sharedStore) {
        // Skip over alloc override below
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

# pragma mark Path management

+ (NSString *)fullPathForImageFilename:(NSString *)name
{
    return [[HistoryItemStore documentPath] stringByAppendingPathComponent:name];
}

+ (UIImage *)imageForFilename:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:[self fullPathForImageFilename:name]];
}

+ (NSString *)documentPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return documentDirectory;
}

+ (NSString *)itemArchivePath
{
    return [[self documentPath] stringByAppendingPathComponent:STR_DATADIR];
}

+ (void)createArchivePath
{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:[self itemArchivePath]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error] == NO)
    {
        NSLog(@"Error creating directory %@: %@", [self itemArchivePath], error.localizedDescription);
    }
}

# pragma mark Items accessors

- (NSArray *)items
{
    return items;
}

- (HistoryItem *)itemForCloudSightQuery:(CloudSightQuery *)query
{
    for (HistoryItem *item in items) {
        if (item.cloudSightQuery == query) {
            return item;
        }
    }
    
    return NULL;
}

- (HistoryItem *)itemForTitle:(NSString *)title
{
    for (HistoryItem *item in items) {
        if ([item.title isEqualToString:title]) {
            return item;
        }
    }
    
    return NULL;
}

- (HistoryItem *)createItemForImage:(UIImage *)image
{
    HistoryItem *item = [[HistoryItem alloc] init];
    [self pushItem:item];
    [self saveImage:image forItem:item];

    return item;
}

- (HistoryItem *)createItemForText:(NSString *)text
{
    HistoryItem *item = [[HistoryItem alloc] init];
    [item setTitle:text];
    [item setIsFound:YES];
    [self pushItem:item];
    
    return item;
}

- (void)removeItemAtIndex:(int)index
{
    HistoryItem *item = [items objectAtIndex:index];
    if (item == nil) {
        return;
    }
    
    [self removeImages:item];
    [items removeObjectAtIndex:index];
    [self saveChanges];
}

- (void)removeItem:(HistoryItem *)item
{
    [self removeImages:item];
    [items removeObject:item];
    [self saveChanges];
}

- (void)pushItem:(HistoryItem *)item
{
    [items insertObject:item atIndex:0];

    if ([items count] > MAX_ITEMS) {
        [self removeImages:[items lastObject]];
        [items removeLastObject];
    }
}

- (void)removeUnfinishedQueries
{
    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (HistoryItem *item in items) {
        if (!item.isFound) {
            // Cancel CloudSight query if exists
            if (item.cloudSightQuery)
                [item.cloudSightQuery stop];
            
            // Add to array remove queue
            [itemsToRemove addObject:item];
        }
    }
    
    NSLog(@"Removing %lu unfinished queries", itemsToRemove.count);
    [items removeObjectsInArray:itemsToRemove];
}

- (BOOL)saveChanges
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:STR_DATAFILE_VER forKey:STR_KEY_VERSION];
    
    if (self.items) {
        NSMutableArray* encodedItemsArray = [NSMutableArray arrayWithCapacity:items.count];
        for (HistoryItem *item in self.items) {
            NSMutableDictionary* queryDictionary = [NSMutableDictionary dictionary];
            [item encodeWithDictionary:queryDictionary];
            
            [encodedItemsArray addObject:queryDictionary];
        }

        [dict setObject:encodedItemsArray forKey:STR_KEY_HISTORY];
    }
    
    NSString* dataFilePath = [[HistoryItemStore itemArchivePath] stringByAppendingPathComponent:STR_DATAFILE];
    return [dict writeToFile:dataFilePath atomically:YES];
}

- (void)saveImage:(UIImage *)image forItem:(HistoryItem *)item
{
    // Save image as a jpg in the data directory.
    // Also create and save a thumbnail suffixed with "thumb".
    // Update query object with the location of image files.
    [HistoryItemStore createArchivePath];
    
    BOOL success = [image saveAsJPEGinDirectory:[HistoryItemStore itemArchivePath] withName:[item imageName]];
    if(!success) {
        NSLog(@"Error saving image: %@/%@", [HistoryItemStore itemArchivePath], [item imageName]);
    }
    
    success = [image saveAsJPEGinDirectory:[HistoryItemStore itemArchivePath] withName:[item thumbName] size:[item thumbSizeInPixels]];
    if(!success) {
        NSLog(@"Error saving thumbnail: %@/%@", [HistoryItemStore itemArchivePath], [item thumbName]);
    }
    
    item.imageFile = [STR_DATADIR stringByAppendingPathComponent:[item imageName]];
    item.thumbFile = [STR_DATADIR stringByAppendingPathComponent:[item thumbName]];    
}

- (void)removeImages:(HistoryItem*)item
{
    NSString* imagePath = [[HistoryItemStore documentPath] stringByAppendingPathComponent:item.imageFile];
    NSString* thumbPath = [[HistoryItemStore documentPath] stringByAppendingPathComponent:item.thumbFile];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if (item.imageFile && ![item.imageFile isEqualToString:@""]) {
        BOOL success = [fileManager removeItemAtPath:imagePath error:nil];
        if (!success) {
            NSLog(@"Error removing: %@", imagePath);
            NSLog(@"%@", error);
        }
    }
    
    if (item.thumbFile && ![item.thumbFile isEqualToString:@""]) {
        BOOL success = [fileManager removeItemAtPath:thumbPath error:nil];
        if (!success) {
            NSLog(@"Error removing: %@", imagePath);
            NSLog(@"%@", error);
        }
    }
    
    item.imageFile = nil;
    item.thumbFile = nil;
}

@end
