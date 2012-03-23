//
//  ARWhereStatement.h
//  iActiveRecord
//
//  Created by Alex Denisov on 23.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARWhereSimpleStatement : NSObject
{
    @private
    NSString *statement;
}

- (id)initWithStatement:(NSString *)aStatement;
- (NSString *)statement;

+ (ARWhereSimpleStatement *)whereField:(NSString *)aField equalToValue:(id)aValue;
+ (ARWhereSimpleStatement *)whereField:(NSString *)aField notEqualToValue:(id)aValue;
+ (ARWhereSimpleStatement *)whereField:(NSString *)aField in:(NSArray *)aValues;
+ (ARWhereSimpleStatement *)whereField:(NSString *)aField notIn:(NSArray *)aValues;

@end
