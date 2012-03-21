//
//  User.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//
#import "User.h"

@implementation User

@synthesize name;
@synthesize ignoredProperty;
@synthesize groupId;

BELONGS_TO_IMP(Group, group)

IGNORE_FIELDS_DO(
    IGNORE_FIELD(ignoredProperty)
)

VALIDATIONS_DO(
    VALIDATE_UNIQUENESS_OF(name)
    VALIDATE_PRESENCE_OF(name)
)

@end
