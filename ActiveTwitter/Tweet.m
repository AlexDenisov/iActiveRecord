//
// Created by Alex Denisov on 25.05.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Tweet.h"

@implementation Tweet

validation_do(
    validate_uniqueness_of(text);
)

@dynamic text;

@end