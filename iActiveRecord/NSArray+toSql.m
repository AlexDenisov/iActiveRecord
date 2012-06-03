//
//  NSArray+toSql.m
//  iActiveRecord
//
//  Created by Alex Denisov on 03.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSArray+toSql.h"
#import "NSString+quotedString.h"

@implementation NSArray (toSql)

- (NSString *)toSql {
    NSMutableArray *sqlValues = [NSMutableArray array];
    for(id value in self){
        [sqlValues addObject:[[value toSql] quotedString]];
    }
    return [NSString stringWithFormat:@"(%@)", [sqlValues componentsJoinedByString:@","]];
}

@end
