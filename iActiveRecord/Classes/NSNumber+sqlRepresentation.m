//
//  NSNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSNumber+sqlRepresentation.h"

@implementation NSNumber (sqlRepresentation)

- (NSString *)toSql {
    return [NSString stringWithFormat:@"%d", [self intValue]];
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSNumber numberWithInteger:[sqlData integerValue]];
}

@end
