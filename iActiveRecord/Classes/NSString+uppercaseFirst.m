//
//  NSString+uppercaseFirst.m
//  iActiveRecord
//
//  Created by Alex Denisov on 15.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+uppercaseFirst.h"

@implementation NSString (uppercaseFirst)

- (NSString *)uppercaseFirst {
    NSString *toUpper = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) 
                                                      withString:[[self substringToIndex:1] uppercaseString]];
    return toUpper; 
}

@end
