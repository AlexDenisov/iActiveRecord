//
//  ARWhereStatement.h
//  iActiveRecord
//
//  Created by Alex Denisov on 23.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ARLogicalAnd,
    ARLogicalOr
} ARLogicalOperation;

@interface ARWhereStatement : NSObject
{
    @private
    NSString *statement;
}

- (id)initWithStatement:(NSString *)aStatement;
- (NSString *)statement;

+ (ARWhereStatement *)whereField:(NSString *)aField equalToValue:(id)aValue;
+ (ARWhereStatement *)whereField:(NSString *)aField notEqualToValue:(id)aValue;
+ (ARWhereStatement *)whereField:(NSString *)aField in:(NSArray *)aValues;
+ (ARWhereStatement *)whereField:(NSString *)aField notIn:(NSArray *)aValues;

+ (ARWhereStatement *)concatenateStatement:(ARWhereStatement *)aFirstStatement 
                                   withStatement:(ARWhereStatement *)aSecondStatement 
                             useLogicalOperation:(ARLogicalOperation)logicalOperation;

@end
