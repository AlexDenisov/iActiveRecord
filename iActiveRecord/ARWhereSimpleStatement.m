//
//  ARWhereStatement.m
//  iActiveRecord
//
//  Created by Alex Denisov on 23.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARWhereSimpleStatement.h"

@implementation ARWhereSimpleStatement

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

+ (ARWhereSimpleStatement *)whereField:(NSString *)aField equalToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ = %@ ",
                      aField,
                      [aValue performSelector:@selector(toSql)]];
    return [[[ARWhereSimpleStatement alloc] initWithStatement:stmt] autorelease];
}

+ (ARWhereSimpleStatement *)whereField:(NSString *)aField notEqualToValue:(id)aValue {
    NSString *stmt = [NSString stringWithFormat:
                      @" %@ <> %@ ",
                      aField,
                      [aValue performSelector:@selector(toSql)]];
    return [[[ARWhereSimpleStatement alloc] initWithStatement:stmt] autorelease];
}

+ (ARWhereSimpleStatement *)whereField:(NSString *)aField in:(NSArray *)aValues {
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[value performSelector:@selector(toSql)]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:@" %@ IN (%@)", aField, values];
    return [[ARWhereSimpleStatement alloc] initWithStatement:stmt];
}

+ (ARWhereSimpleStatement *)whereField:(NSString *)aField notIn:(NSArray *)aValues {
    NSMutableArray *sqlValues = [NSMutableArray arrayWithCapacity:aValues.count];
    for(id value in aValues){
        [sqlValues addObject:[value performSelector:@selector(toSql)]];
    }
    NSString *values = [sqlValues componentsJoinedByString:@" , "];
    NSString *stmt = [NSString stringWithFormat:@" %@ NOT IN (%@)", aField, values];
    return [[ARWhereSimpleStatement alloc] initWithStatement:stmt];
}

- (NSString *)statement {
    return statement;
}


@end

