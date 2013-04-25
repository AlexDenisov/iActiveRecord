//
//  NSDecimalNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 18.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSDecimalNumber+sqlRepresentation.h"

@implementation NSDecimalNumber (sqlRepresentation)

+ (NSLocale *)posixLocale {
    static NSLocale *posixLocale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    return posixLocale;
}

- (NSString *)toSql {
    return [self descriptionWithLocale:[NSDecimalNumber posixLocale]];
}

+ (NSString *)sqlType {
    return @"text";
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSDecimalNumber decimalNumberWithString:sqlData locale:[NSDecimalNumber posixLocale]];
}

@end
