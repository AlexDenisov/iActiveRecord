//
//  NSString+quotedString.m
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+quotedString.h"

@implementation NSString (quotedString)

- (NSString *)quotedString {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

@end
