//
//  Group.h
//  iActiveRecord
//
//  Created by mls on 10.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActiveRecord.h"

@interface Group : ActiveRecord
    <ARValidatableProtocol>

@property (nonatomic, copy) NSString *name;

HAS_MANY_DEC(User, users)

@end
