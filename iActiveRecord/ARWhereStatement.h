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

- (id)initWithStatement:(NSString *)aStatement;
- (NSString *)statement;

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord equalToValue:(id)aValue;
+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notEqualToValue:(id)aValue;
+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord in:(NSArray *)aValues;
+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notIn:(NSArray *)aValues;

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord like:(NSString *)aPattern;
+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notLike:(NSString *)aPattern;

+ (ARWhereStatement *)whereField:(NSString *)aField 
                        ofRecord:(Class)aRecord 
                         between:(id)startValue 
                             and:(id)endValue;

+ (ARWhereStatement *)concatenateStatement:(ARWhereStatement *)aFirstStatement 
                                   withStatement:(ARWhereStatement *)aSecondStatement 
                             useLogicalOperation:(ARLogicalOperation)logicalOperation;

@end
