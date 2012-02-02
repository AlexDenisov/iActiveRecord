//
//  NSNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by mls on 17.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
