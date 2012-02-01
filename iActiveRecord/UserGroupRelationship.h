//
//  UserGroupRelationship.h
//  iActiveRecord
//
//  Created by mls on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActiveRecord.h"

@interface UserGroupRelationship : ActiveRecord

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSNumber *groupId;

@end
