//
//  Project.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"

/*
    Project has many users
 */

@interface Project : ActiveRecord

@property (nonatomic, copy) NSString *name;

HAS_MANY_THROUGH_DEC(User, UserProjectRelationship, users)

@end
