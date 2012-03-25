//
//  NSData+sqlRepresentation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (sqlRepresentation)

- (NSString *)toSql;
+ (id)fromSql:(NSString *)sqlData;
+ (const char *)sqlType;

@end
