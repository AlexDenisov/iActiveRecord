//
//  Project.m
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Project.h"

@implementation Project

@dynamic name;

has_many_through_imp(User, UserProjectRelationship, users, ARDependencyDestroy)
has_many_imp(Issue, issues, ARDependencyDestroy)
has_many_through_imp(Group, ProjectGroupRelationsShip, groups, ARDependencyNullify)

validation_do(
    validate_presence_of(name)
    validate_uniqueness_of(name)
)

@end
