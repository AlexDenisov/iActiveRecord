//
//  NSData+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSData+sqlRepresentation.h"

@implementation NSData (sqlRepresentation)

- (NSString *)toSql {
    NSString *str = [[NSString alloc] initWithData:self
                                          encoding:NSUTF8StringEncoding];
    return [str autorelease];
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSData dataWithBytes:[sqlData UTF8String]
                                  length:[sqlData length]];
}

+ (const char *)sqlType {
    return "blob";
}

@end
