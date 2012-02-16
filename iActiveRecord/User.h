//
//  User.h
//  iActiveRecord
//
//  Created by mls on 10.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActiveRecord.h"

@interface User : ActiveRecord
    <ARValidatableProtocol>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *ignoredProperty;
@property (nonatomic, retain) NSNumber *groupId;

@end
