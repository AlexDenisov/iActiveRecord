//
//  NSSet+toSql.m
//  iActiveRecord
//
//  Created by Alex Denisov on 03.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSSet+toSql.h"

@implementation NSSet (toSql)

- (NSString *)toSql {
    return [[self allObjects] performSelector:@selector(toSql)];
}

@end
