//
//  NSURL+toSql.m
//  iActiveRecord
//
//  Created by PAC on 26/11/2014.
//  Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "NSURL+sqlRepresentation.h"

@implementation NSURL (sqlRepresentation)

- (NSString *)toSql {
    return [self absoluteString];
}

+ (id)fromSql:(NSString *)sqlData {
    return [NSURL URLWithString:sqlData];
}

+ (const char *)sqlType {
    return "nsurl";
}

@end
