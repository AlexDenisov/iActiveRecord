//
// Created by Alex Denisov on 25.05.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

typedef void (^SearchFinishedSuccessful) (NSArray *tweets);
typedef void (^SearchFailed) (NSError *error);

@interface ATSearchManager : NSObject

- (void)searchForKeyword:(NSString *)keyword
             withSuccess:(SearchFinishedSuccessful)success
                 failure:(SearchFailed)failure;

@end