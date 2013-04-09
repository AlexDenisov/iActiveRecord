//
//  ProjectGroupRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"

@interface ProjectGroupRelationship : ActiveRecord

@property (nonatomic, retain) NSNumber *projectId;
@property (nonatomic, retain) NSNumber *groupId;

@end
