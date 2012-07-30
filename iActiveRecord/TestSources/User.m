//
//  User.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//
#import "User.h"

@implementation User

@dynamic name;
@synthesize ignoredProperty;
@dynamic groupId;

@dynamic imageData;

belongs_to_imp(Group, group, ARDependencyDestroy)
has_many_through_imp(Project, UserProjectRelationship, projects, ARDependencyDestroy)

validation_do(
    validate_uniqueness_of(name)
    validate_presence_of(name)
)

indices_do(
    add_index_on(name)
)

@end
