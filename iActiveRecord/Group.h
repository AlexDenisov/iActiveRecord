//
//  Group.h
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"
#import "User.h"

/*
    Group has many users
 */

@interface Group : ActiveRecord
    <ARValidatableProtocol>

@property (nonatomic, copy) NSString *name;

has_many_dec(User, users, ARDependencyDestroy)

@end
