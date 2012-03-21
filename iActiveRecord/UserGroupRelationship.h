//
//  UserGroupRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"

@interface UserGroupRelationship : ActiveRecord

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSNumber *groupId;

@end
