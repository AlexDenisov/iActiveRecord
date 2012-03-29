//
//  NSDate+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 29.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSDate+sqlRepresentation.h"

@implementation NSDate (sqlRepresentation)

- (NSString *)toSql {
    NSTimeInterval time = [self timeIntervalSince1970];
    return [NSString stringWithFormat:@"%f", time];
}

+ (id)fromSql:(NSString *)sqlData {
    NSTimeInterval time = [sqlData floatValue];
    return [NSDate dateWithTimeIntervalSince1970:time];
}

+ (const char *)sqlType {
    return "INTEGER";
}

@end
