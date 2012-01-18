//
//  NSDecimalNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by mls on 18.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDecimalNumber+sqlRepresentation.h"

@implementation NSDecimalNumber (sqlRepresentation)

- (NSString *)toSql {
    return [NSString stringWithFormat:@"%@", [self floatValue]];
}

+ (const char *)sqlType {
    return "integer";
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSDecimalNumber decimalNumberWithString:sqlData];
}

@end
