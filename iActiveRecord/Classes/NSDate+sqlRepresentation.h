//
//  NSDate+sqlRepresentation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (sqlRepresentation)

- (NSString *)toSql;
+ (id)fromSql:(NSString *)sqlData;

@end
