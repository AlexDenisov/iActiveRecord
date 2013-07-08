//
//  NSDate+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 29.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSDate+sqlRepresentation.h"

@implementation NSDate (sqlRepresentation)

- (NSString *)toSql {
    NSTimeInterval time = [self timeIntervalSince1970];
    return [NSString stringWithFormat:@"%f", time];
}

+ (id)fromSql:(NSString *)sqlData {
    NSTimeInterval time = [sqlData doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:time];
}

@end
