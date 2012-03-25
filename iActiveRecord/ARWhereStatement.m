//
//  ARWhereStatement.m
//  iActiveRecord
//
//  Created by Alex Denisov on 23.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARWhereStatement.h"
#import "NSString+quotedString.h"

@interface ARWhereStatement (Private)

+ (ARWhereStatement *)statement:(NSString *)aStmt;

@end

@implementation ARWhereStatement

- (id)initWithStatement:(NSString *)aStatement {
    self = [super init];
    if(nil != self){
        statement = [aStatement copy];
    }
    return self;
}

- (void)dealloc {
    [statement release];
    [super dealloc];
}

+ (ARWhereStatement *)statement:(NSString *)aStmt {
    return [[[ARWhereStatement alloc] initWithStatement:aStmt] autorelease];
}

#warning TODO: refactor!!!

+ (ARWhereStatement *)whereField:(NSString *)aField equalToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ = %@ ",
                      [aField quotedString],
                      [[aValue performSelector:@selector(toSql)] quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField notEqualToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ <> %@ ",
                      [aField quotedString],
                      [[aValue performSelector:@selector(toSql)] quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField in:(NSArray *)aValues {
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[[value performSelector:@selector(toSql)] quotedString]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:@" %@ IN (%@)", [aField quotedString], values];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField notIn:(NSArray *)aValues {
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[[value performSelector:@selector(toSql)] quotedString]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:@" %@ NOT IN (%@)", [aField quotedString], values];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord equalToValue:(id)aValue 
{
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ = %@ ",
                      [[aRecord performSelector:@selector(tableName)] quotedString],
                      [aField quotedString],
                      [[aValue performSelector:@selector(toSql)] quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notEqualToValue:(id)aValue 
{
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ <> %@ ",
                      [[aRecord performSelector:@selector(tableName)] quotedString],
                      [aField quotedString],
                      [[aValue performSelector:@selector(toSql)] quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord in:(NSArray *)aValues
{
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[[value performSelector:@selector(toSql)] quotedString]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ IN (%@)",
                      [[aRecord performSelector:@selector(tableName)] quotedString],
                      [aField quotedString], 
                      values];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notIn:(NSArray *)aValues
{
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[[value performSelector:@selector(toSql)] quotedString]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ NOT IN (%@)", 
                      [[aRecord performSelector:@selector(tableName)] quotedString],
                      [aField quotedString], 
                      values];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)concatenateStatement:(ARWhereStatement *)aFirstStatement 
                                   withStatement:(ARWhereStatement *)aSecondStatement
                             useLogicalOperation:(ARLogicalOperation)logicalOperation
{
    NSString *logic = logicalOperation == ARLogicalOr ? @"OR" : @"AND";
    NSString *stmt = [NSString stringWithFormat:
                      @" (%@) %@ (%@) ", 
                      [aFirstStatement statement],
                      logic,
                      [aSecondStatement statement]];
    return [ARWhereStatement statement:stmt];
}

- (NSString *)statement {
    return statement;
}


@end

