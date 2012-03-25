//
//  NSString+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+sqlRepresentation.h"

@implementation NSString (sqlRepresentation)

+ (id)fromSql:(NSString *)sqlData{
    return sqlData;
}

- (NSString *)toSql {
    return self;
}

+ (const char *)sqlType {
    return "text";
}

@end
