//
//  NSString+isPresented.m
//  iActiveRecord
//
//  Created by Alex Denisov on 11.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSString+isPresented.h"

@implementation NSString (isPresented)

- (BOOL)isPresented {
    return (self != nil) && (self.length);
}

@end
