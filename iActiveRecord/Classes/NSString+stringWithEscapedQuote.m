//
//  NSString+stringWithEscapedQuote.m
//  iActiveRecord
//
//  Created by Alex Denisov on 05.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSString+stringWithEscapedQuote.h"

@implementation NSString (stringWithEscapedQuote)

- (NSString *)stringWithEscapedQuote {
    return [self stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
}

@end
