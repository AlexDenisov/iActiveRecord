//
//  NSNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSNumber+sqlRepresentation.h"

@implementation NSNumber (sqlRepresentation)

- (NSString *)toSql {
    return [NSString stringWithFormat:@"%d", [self intValue]];
}

+ (const char *)sqlType {
    return "integer";
}

+ (id)fromSql:(NSString *)sqlData{
    return [NSNumber numberWithInteger:[sqlData integerValue]];
}

@end
