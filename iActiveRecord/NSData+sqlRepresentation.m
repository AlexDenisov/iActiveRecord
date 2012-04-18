//
//  NSData+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSData+sqlRepresentation.h"

#import "NSData+Base64.h"

@implementation NSData (sqlRepresentation)

- (NSString *)toSql {
    return [self base64EncodedString];
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSData dataFromBase64String:sqlData];
}

+ (const char *)sqlType {
    return "blob";
}

@end
