//
//  NSObject+properties.h
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (properties)

+ (NSArray *)activeRecordProperties;
+ (NSString *)propertyClassNameWithPropertyName:(NSString *)aName;

@end
