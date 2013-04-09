//
//  NSNumber+sqlRepresentation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (sqlRepresentation)

+ (NSString *)sqlType;
- (NSString *)toSql;
+ (id)fromSql:(NSString *)sqlData;

@end
