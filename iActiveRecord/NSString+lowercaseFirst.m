//
//  NSString+lowercaseFirst.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+lowercaseFirst.h"

@implementation NSString (lowercaseFirst)

- (NSString *)lowercaseFirst {
    NSString *toLower = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) 
                                                      withString:[[self substringToIndex:1] lowercaseString]];
    return toLower;
}

@end 
