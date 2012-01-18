//
//  NSDecimalNumber+sqlRepresentation.h
//  iActiveRecord
//
//  Created by mls on 18.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (sqlRepresentation)

+ (const char *)sqlType;
- (NSString *)toSql;
+ (id)fromSql:(NSString *)sqlData;

@end
