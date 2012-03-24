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

belonsg_to_imp(Group, group)
has_many_through_imp(Project, UserProjectRelationship, projects)

ignore_fields_do(
    ignore_field(ignoredProperty)
)

validation_do(
    validate_uniqueness_of(name)
    validate_presence_of(name)
)

@end
