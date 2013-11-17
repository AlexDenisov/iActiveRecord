//
//  DifferentTableName.m
//  iActiveRecord
//
//  Created by Alex Denisov on 07.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "DifferentTableName.h"

@implementation DifferentTableName

@dynamic title;
@dynamic userId;

belongs_to_imp(User, user, ARDependencyDestroy);

+ (NSString *)recordName {
    return @"different_table_name";
}

@end
