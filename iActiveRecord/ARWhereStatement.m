//
//  ARWhereStatement.m
//  iActiveRecord
//
//  Created by Alex Denisov on 23.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARWhereStatement.h"
#import "ARWhereStatement_Private.h"
#import "NSString+quotedString.h"
#import "NSString+stringWithEscapedQuote.h"

@implementation ARWhereStatement

#pragma mark - private

+ (ARWhereStatement *)statement:(NSString *)aStmt {
    return [[[ARWhereStatement alloc] initWithStatement:aStmt] autorelease];
}

+ (ARWhereStatement *)statementForField:(NSString *)aField 
                              fromArray:(NSArray *)aValues 
                          withOperation:(NSString *)anOperation
{
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[[[value performSelector:@selector(toSql)] 
                               stringWithEscapedQuote] 
                              quotedString]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:@" %@ %@ (%@)", 
                      aField, 
                      anOperation,
                      values];
    return [ARWhereStatement statement:stmt];
}

#pragma mark - public

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

+ (ARWhereStatement *)whereField:(NSString *)aField equalToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ = %@ ",
                      [aField quotedString],
                      [[[aValue performSelector:@selector(toSql)] 
                        stringWithEscapedQuote] 
                       quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField 
                        ofRecord:(Class)aRecord 
                         between:(id)startValue 
                             and:(id)endValue
{
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ BETWEEN %@ AND %@", 
                      [[aRecord performSelector:@selector(recordName)] quotedString],
                      [aField quotedString],
                      [[startValue performSelector:@selector(toSql)] quotedString],
                      [[endValue performSelector:@selector(toSql)] quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField 
                        ofRecord:(Class)aRecord 
                            like:(NSString *)aPattern 
{
    NSString *pattern = [[NSString stringWithFormat:@"%@", aPattern] quotedString];
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ LIKE %@ ",
                      [[aRecord performSelector:@selector(recordName)] quotedString],
                      [aField quotedString],
                      pattern];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField 
                        ofRecord:(Class)aRecord 
                         notLike:(NSString *)aPattern
{
    NSString *pattern = [[NSString stringWithFormat:@"%@", aPattern] quotedString];
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ NOT LIKE %@ ",
                      [[aRecord performSelector:@selector(recordName)] quotedString],
                      [aField quotedString],
                      pattern];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField notEqualToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ <> %@ ",
                      [aField quotedString],
                      [[[aValue performSelector:@selector(toSql)] 
                        stringWithEscapedQuote]
                       quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField in:(NSArray *)aValues {
    return [self statementForField:[aField quotedString]
                         fromArray:aValues
                     withOperation:@"IN"];
}

+ (ARWhereStatement *)whereField:(NSString *)aField notIn:(NSArray *)aValues {
    return [self statementForField:[aField quotedString]
                         fromArray:aValues
                     withOperation:@"NOT IN"];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord equalToValue:(id)aValue 
{
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ = %@ ",
                      [[aRecord performSelector:@selector(recordName)] quotedString],
                      [aField quotedString],
                      [[[aValue performSelector:@selector(toSql)] 
                        stringWithEscapedQuote] 
                       quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notEqualToValue:(id)aValue 
{
    NSString *stmt = [NSString stringWithFormat:
                      @" %@.%@ <> %@ ",
                      [[aRecord performSelector:@selector(recordName)] quotedString],
                      [aField quotedString],
                      [[[aValue performSelector:@selector(toSql)] 
                        stringWithEscapedQuote] 
                       quotedString]];
    return [ARWhereStatement statement:stmt];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord in:(NSArray *)aValues
{
    NSString *field = [NSString stringWithFormat:
                       @"%@.%@", 
                       [[aRecord performSelector:@selector(recordName)] quotedString],
                       [aField quotedString]];
    return [self statementForField:field
                         fromArray:aValues
                     withOperation:@"IN"];
}

+ (ARWhereStatement *)whereField:(NSString *)aField ofRecord:(Class)aRecord notIn:(NSArray *)aValues
{
    NSString *field = [NSString stringWithFormat:
                       @"%@.%@", 
                       [[aRecord performSelector:@selector(recordName)] quotedString],
                       [aField quotedString]];
    return [self statementForField:field
                         fromArray:aValues
                     withOperation:@"NOT IN"];
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

