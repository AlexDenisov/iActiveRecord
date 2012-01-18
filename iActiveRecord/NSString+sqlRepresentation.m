//
//  NSString+sqlRepresentation.m
//  iActiveRecord
//
//  Created by mls on 17.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+sqlRepresentation.h"

@implementation NSString (sqlRepresentation)

+ (id)fromSql:(NSString *)sqlData{
    return sqlData;
}

- (NSString *)toSql {
    return [NSString stringWithFormat:@"'%@'", self];
}

+ (const char *)sqlType {
    return "text";
}

@end
