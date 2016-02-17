//
//  UPCDatabaseDelegate.h
//  Eyedentify
//
//  Created by Bradford Folkens on 1/13/13.
//  Copyright (c) 2013 ImageSearcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPCDatabase;

@protocol UPCDatabaseDelegate <NSObject>

- (void)upcDatabase:(UPCDatabase *)db didFindProduct:(NSString *)name;
- (void)upcDatabase:(UPCDatabase *)db didFinishWithError:(NSError *)error;

@end
