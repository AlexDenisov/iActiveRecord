//
//  NSData+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSData+sqlRepresentation.h"

@implementation NSData (sqlRepresentation)

- (NSString *)toSql {
    return @"";
}

+ (id)fromSql:(NSString *)sqlData {
    return nil;
}

+ (NSString *)sqlType {
    return @"blob";
}

@end
