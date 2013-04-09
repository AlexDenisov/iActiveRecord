//
//  UserProjectRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"

@interface UserProjectRelationship : ActiveRecord

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSNumber *projectId;

@end
