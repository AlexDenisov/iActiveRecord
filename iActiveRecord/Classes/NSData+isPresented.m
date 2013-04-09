//
//  NSData+isPresented.m
//  iActiveRecord
//
//  Created by Alex Denisov on 11.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSData+isPresented.h"

@implementation NSData (isPresented)

- (BOOL)isPresented {
    return (self != nil) && (self.length);
}

@end
