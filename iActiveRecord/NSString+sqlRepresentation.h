//
//  NSString+sqlRepresentation.h
//  iActiveRecord
//
//  Created by mls on 17.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (sqlRepresentation)

+ (const char *)sqlType;
- (NSString *)toSql;

@end
