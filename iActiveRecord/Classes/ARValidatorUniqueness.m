//
//  ARValidatorUniqueness.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARValidatorUniqueness.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import <objc/runtime.h>

@implementation ARValidatorUniqueness

- (NSString *)errorMessage {
    return kARFieldAlreadyExists;
}

- (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
    NSString *recordName = [[aRecord class] description];
    id aValue = [aRecord valueForKey:aField];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(recordName)];
    [fetcher where:@"%@ = %@", aField, aValue, nil];
    NSInteger count = [fetcher count];
    if(count){
        return NO;
    }
    return YES;
}

@end
