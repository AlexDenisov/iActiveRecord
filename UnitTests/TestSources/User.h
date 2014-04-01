//
//  User.h
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ActiveRecord.h"

/*
    User belongs to group
    and has many projects
 */

@interface User : ActiveRecord

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *ignoredProperty;
//  used in belongs to relationship
@property (nonatomic, retain) NSNumber *groupId;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) NSDate *birthDate;
belongs_to_dec(Group, group, ARDependencyDestroy)
has_many_through_dec(Project, UserProjectRelationship, projects, ARDependencyDestroy)
has_many_through_dec(Animal, UserAnimalRelationship, pets, ARDependencyDestroy)

@end
