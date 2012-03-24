//
//  Group.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize name;

has_many_imp(User, users)

validation_do(
    validate_uniqueness_of(name)
)

@end
