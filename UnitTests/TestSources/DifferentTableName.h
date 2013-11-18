//
//  DifferentTableName.h
//  iActiveRecord
//
//  Created by Alex Denisov on 07.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import <ActiveRecord/ActiveRecord.h>

@interface DifferentTableName : ActiveRecord

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber* userId;

belongs_to_dec(User, user, ARDependencyDestroy)

@end
