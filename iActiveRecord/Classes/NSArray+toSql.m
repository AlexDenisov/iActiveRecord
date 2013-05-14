//
//  NSArray+toSql.m
//  iActiveRecord
//
//  Created by Alex Denisov on 03.06.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSArray+toSql.h"

@implementation NSArray (toSql)

- (NSString *)toSql {
    NSMutableArray *sqlValues = [NSMutableArray array];
    for (id value in self) {
        NSString *escapedSql = [NSString stringWithFormat:@"\"%@\"", [value toSql]];
        [sqlValues addObject:escapedSql];
    }
    return [NSString stringWithFormat:@"(%@)", [sqlValues componentsJoinedByString:@","]];
}

@end
