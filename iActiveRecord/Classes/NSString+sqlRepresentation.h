//
//  NSString+sqlRepresentation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (sqlRepresentation)

//+ (NSString *)sqlType;
+ (id)fromSql:(NSString *)sqlData;
- (NSString *)toSql;

@end
