//
//  Project.m
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Project.h"

@implementation Project

@synthesize name;

HAS_MANY_THROUGH_IMP(User, UserProjectRelationship, users)

VALIDATIONS_DO(
    VALIDATE_PRESENCE_OF(name)
    VALIDATE_UNIQUENESS_OF(name)
)

@end
