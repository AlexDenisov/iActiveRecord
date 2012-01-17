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
    return [NSString stringWithFormat:@"%@", [self floatValue]];
}

+ (const char *)sqlType {
    return "real";
}
@end
