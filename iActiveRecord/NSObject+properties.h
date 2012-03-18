//
//  NSObject+properties.h
//  iActiveRecord
//
//  Created by mls on 10.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (properties)

+ (NSArray *)activeRecordProperties;
+ (NSString *)propertyClassNameWithPropertyName:(NSString *)aName;

@end
