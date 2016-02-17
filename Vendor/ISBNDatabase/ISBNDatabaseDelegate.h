//
//  ISBNDatabaseDelegate.h
//  Eyedentify
//
//  Created by Bradford Folkens on 1/13/13.
//  Copyright (c) 2013 ImageSearcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISBNDatabase;

@protocol ISBNDatabaseDelegate <NSObject>

- (void)isbnDatabase:(ISBNDatabase *)db didFindProduct:(NSString *)name;
- (void)isbnDatabase:(ISBNDatabase *)db didFinishWithError:(NSError *)error;

@end
