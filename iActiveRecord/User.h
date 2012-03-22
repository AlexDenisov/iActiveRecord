//
//  User.h
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"

/*
    User belongs to group
    and has many projects
 */

@interface User : ActiveRecord
    <ARValidatableProtocol>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *ignoredProperty;
//  used in belongs to relationship
@property (nonatomic, retain) NSNumber *groupId;

BELONGS_TO_DEC(Group, group)
HAS_MANY_THROUGH_DEC(Project, UserProjectRelationship, projects)

@end
