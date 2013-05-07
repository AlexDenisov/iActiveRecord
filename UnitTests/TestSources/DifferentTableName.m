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

+ (NSString *)recordName {
    return @"different_table_name";
}

@end
