//
//  Group.m
//  iActiveRecord
//
//  Created by mls on 10.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize name;

HAS_MANY_IMP(User, users)

VALIDATIONS_DO(
    VALIDATE_UNIQUENESS_OF(name)
)

@end
