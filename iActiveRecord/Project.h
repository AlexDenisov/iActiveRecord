//
//  Project.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"
#import "User.h"

/*
    Project has many users
 */

@interface Project : ActiveRecord

@property (nonatomic, copy) NSString *name;

has_many_through_dec(User, UserProjectRelationship, users, ARDependencyDestroy)

@end
