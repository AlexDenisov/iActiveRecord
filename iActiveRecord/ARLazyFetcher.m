//
//  ARLazyFetcher.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARLazyFetcher.h"
#import "ARDatabaseManager.h"
#import "ARWhereStatement.h"
#import "NSString+lowercaseFirst.h"
#import "NSString+quotedString.h"
#import "ARColumn.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARLazyFetcher_Private.h"
#import "ARWhereStatement_Private.h"

@implementation ARLazyFetcher

- (id)init {
    self = [super init];
    if(nil != self){
        limit = nil;
        offset = nil;
        sqlRequest = nil;
        orderByConditions = nil;
        useJoin = NO;
    }
    return self;
}

- (id)initWithRecord:(Class)aRecord
{
    self = [self init];
    recordClass = aRecord;
    return self;
}

- (id)initWithRecord:(Class)aRecord withInitialSql:(NSString *)anInitialSql {
    self = [self initWithRecord:aRecord];
    if(self){
        sqlRequest = [anInitialSql copy];
    }
    return self;
}

- (void)dealloc {
    [recordField release];
    [joinField release];
    [onlyFields release];
    [exceptFields release];
    [whereStatement release];
    [orderByConditions release];
    [sqlRequest release];
    [limit release];
    [offset release];
    [super dealloc];
}

#pragma mark - Building SQL request

- (NSSet *)fieldsOfRecord:(ActiveRecord *)aRecord {
    NSMutableSet *fields = [NSMutableSet set];
    if(onlyFields){
        [fields addObjectsFromArray:[onlyFields allObjects]];
    }else {
        NSArray *columns = [aRecord columns];
        for(ARColumn *column in columns){
            [fields addObject:column.columnName];
        }
    }
    if(exceptFields){
        for(NSString *field in exceptFields){
            [fields removeObject:field];
        }
    }
    return fields;
}

- (NSSet *)recordFields {
    return [self fieldsOfRecord:recordClass];
}

- (void)buildSql {
    NSMutableString *sql = [NSMutableString string];
    
    NSString *select = [self createSelectStatement];
    NSString *limitOffset = [self createLimitOffsetStatement];
    NSString *orderBy = [self createOrderbyStatement];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];
    
    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    [sql appendString:orderBy];
    [sql appendString:limitOffset];
    sqlRequest = [sql copy];
}

- (NSString *)createWhereStatement {
    NSMutableString *statement = [NSMutableString string];
    if(whereStatement){
        [statement appendFormat:@" WHERE (%@) ", [whereStatement statement]];
    }
    return statement;
}

- (NSString *)createOrderbyStatement {
    NSMutableString *statement = [NSMutableString string];
    if(orderByConditions){
        [statement appendFormat:@" ORDER BY "];
        for(NSString *key in [orderByConditions allKeys]){
            NSString *order = [[orderByConditions valueForKey:key] boolValue] ? @"ASC" : @"DESC";
            [statement appendFormat:
             @" %@.%@ %@ ,", 
             [[recordClass performSelector:@selector(recordName)] quotedString], 
             [key quotedString], 
             order];
        }
        [statement replaceCharactersInRange:NSMakeRange(statement.length - 1, 1) withString:@""];
    }
    return statement;
}

- (NSString *)createLimitOffsetStatement {
    NSMutableString *statement = [NSMutableString string];
    NSInteger limitNum = -1;
    if(limit){
        limitNum = limit.integerValue;
    }
    [statement appendFormat:@" LIMIT %d ", limitNum];
    if(offset){
        [statement appendFormat:@" OFFSET %d ", offset.integerValue];
    }
    return statement;
}

- (NSString *)createJoinedSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for(NSString *field in [self fieldsOfRecord:recordClass]){
        fieldname = [NSString stringWithFormat:
                     @"%@.%@ AS '%@#%@'", 
                     [[recordClass performSelector:@selector(recordName)] quotedString],
                     [field quotedString],
                     [recordClass performSelector:@selector(recordName)],
                     field];
        [fields addObject:fieldname];
    }
    
    for(NSString *field in [self fieldsOfRecord:joinClass]){
        fieldname = [NSString stringWithFormat:
                     @"%@.%@ AS '%@#%@'", 
                     [[joinClass performSelector:@selector(recordName)] quotedString],
                     [field quotedString],
                     [joinClass performSelector:@selector(recordName)],
                     field];
        [fields addObject:fieldname];
    }
    
    [statement appendFormat:
     @"%@ FROM %@ ", 
     [fields componentsJoinedByString:@","], 
     [[recordClass performSelector:@selector(recordName)] quotedString]];
    return statement;
}

- (NSString *)createSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for(NSString *field in [self recordFields]){
        fieldname = [NSString stringWithFormat:
                     @"%@.%@", 
                     [[recordClass performSelector:@selector(recordName)] quotedString],
                     [field quotedString]];
        [fields addObject:fieldname];
    }
    [statement appendFormat:
     @"%@ FROM %@ ", 
     [fields componentsJoinedByString:@","], 
     [[recordClass performSelector:@selector(recordName)] quotedString]];
    return statement;
}

- (NSString *)createJoinStatement {
    NSMutableString *statement = [NSMutableString string];
    if (useJoin){
        NSString *join = joinString(joinType);
        NSString *joinTable = [joinClass performSelector:@selector(recordName)];
        NSString *selfTable = [recordClass performSelector:@selector(recordName)];
        [statement appendFormat:
         @" %@ JOIN %@ ON %@.%@ = %@.%@ ", 
         join, 
         [joinTable quotedString],
         [selfTable quotedString], [recordField quotedString],
         [joinTable quotedString], [joinField quotedString]];
    }
    return statement;
}

#pragma mark - Helpers

- (ARLazyFetcher *)offset:(NSInteger)anOffset {
    [offset release];
    offset = [[NSNumber alloc] initWithInteger:anOffset];
    return self;
}

- (ARLazyFetcher *)limit:(NSInteger)aLimit {
    [limit release];
    limit = [[NSNumber alloc] initWithInteger:aLimit];
    return self;
}

#pragma mark - Where Conditions

- (ARWhereStatement *)whereStatement {
    return whereStatement;
}

- (ARLazyFetcher *)setWhereStatement:(ARWhereStatement *)aStatement {
    if([whereStatement isEqual:aStatement]){
        return self;
    }
    [whereStatement release];
    whereStatement = [aStatement retain];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                      between:(id)startValue 
                          and:(id)endValue
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:recordClass
                                                   between:startValue
                                                       and:endValue];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField like:(NSString *)aPattern {
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:recordClass
                                                      like:aPattern];
    [self setWhereStatement:where];
    return self;
}
- (ARLazyFetcher *)whereField:(NSString *)aField notLike:(NSString *)aPattern {
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:recordClass
                                                   notLike:aPattern];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue {
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:recordClass
                                              equalToValue:aValue];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue {
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:recordClass
                                           notEqualToValue:aValue];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues {
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:recordClass
                                                        in:aValues];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues {
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:recordClass
                                                     notIn:aValues];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                 equalToValue:(id)aValue 
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:aRecord
                                              equalToValue:aValue];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
              notEqualToValue:(id)aValue 
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:aRecord
                                           notEqualToValue:aValue];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                           in:(NSArray *)aValues 
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:aRecord
                                                        in:aValues];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                        notIn:(NSArray *)aValues
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:aRecord
                                                     notIn:aValues];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                         like:(NSString *)aPattern
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:aRecord
                                                      like:aPattern];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                      notLike:(NSString *)aPattern
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField 
                                                  ofRecord:aRecord
                                                   notLike:aPattern];
    [self setWhereStatement:where];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                      between:(id)startValue 
                          and:(id)endValue
{
    ARWhereStatement *where = [ARWhereStatement whereField:aField
                                                  ofRecord:aRecord
                                                   between:startValue
                                                       and:endValue];
    [self setWhereStatement:where];
    return self;
}

#pragma mark - OrderBy

- (ARLazyFetcher *)orderBy:(NSString *)aField
                 ascending:(BOOL)isAscending
{
    if(orderByConditions == nil){
        orderByConditions = [NSMutableDictionary new];
    }
    NSNumber *ascending = [NSNumber numberWithBool:isAscending];
    [orderByConditions setValue:ascending
                         forKey:aField];
    return self;
}

- (ARLazyFetcher *)orderBy:(NSString *)aField {
    return [self orderBy:aField ascending:YES];
}

#pragma mark - Select

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... {
    if(onlyFields == nil){
        onlyFields = [NSMutableSet new];
    }
    [onlyFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while((field = va_arg(args, NSString *))) {
        [onlyFields addObject:field];
    }
    va_end(args);
    return self;
}

- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... {
    if(exceptFields == nil){
        exceptFields = [NSMutableSet new];
    }
    [exceptFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while((field = va_arg(args, NSString *))) {
        [exceptFields addObject:field];
    }
    va_end(args);
    return self;
}

#pragma mark - Joins

- (ARLazyFetcher *)join:(Class)aJoinRecord {
    
    NSString *_recordField = @"id";
    NSString *_joinField = [NSString stringWithFormat:
                 @"%@Id",
                 [[recordClass description] lowercaseFirst]];
    [self join:aJoinRecord 
       useJoin:ARJoinInner 
       onField:_recordField
      andField:_joinField];    
    return self;
}

- (ARLazyFetcher *)join:(Class)aJoinRecord 
                useJoin:(ARJoinType)aJoinType 
                onField:(NSString *)aFirstField 
               andField:(NSString *)aSecondField
{
    joinClass = aJoinRecord;
    joinType = aJoinType;
    [recordField release];
    recordField = [aFirstField copy];
    [joinField release];
    joinField = [aSecondField copy];
    useJoin = YES;
    return self;
}

#pragma mark - Immediately fetch

- (NSArray *)fetchRecords {
    [self buildSql];
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:[recordClass description]
                                                          withSql:sqlRequest];
}

- (NSArray *)fetchJoinedRecords {
    if(!useJoin){
        [NSException raise:@"InvalidCall"
                    format:@"Call this method only with JOIN"];
    }
    NSMutableString *sql = [NSMutableString string];
    
    NSString *select = [self createJoinedSelectStatement];
    NSString *limitOffset = [self createLimitOffsetStatement];
    NSString *orderBy = [self createOrderbyStatement];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];
    
    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    [sql appendString:orderBy];
    [sql appendString:limitOffset];
    return [[ARDatabaseManager sharedInstance] joinedRecordsWithSql:sql];
}

- (NSInteger)count {
    NSMutableString *sql = [NSMutableString string];
    
    NSString *select = [NSString stringWithFormat:
                        @"SELECT count(*) FROM %@ ", 
                        [[recordClass performSelector:@selector(recordName)] quotedString]];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];
    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    return [[ARDatabaseManager sharedInstance] functionResult:sql];
}

- (ARLazyFetcher *)where:(NSString *)aCondition, ... {
    va_list args;
    NSMutableArray *sqlArguments = [NSMutableArray array];
    NSString *argument = nil;
    va_start(args, aCondition);
    id value = nil;
    while ((value = va_arg(args, id))) {
        if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]){
            argument = [value performSelector:@selector(toSql)];
        }else{
            argument = [[value performSelector:@selector(toSql)] quotedString];
        }
        [sqlArguments addObject:argument]; 
    }
    va_end(args);

    char *argList = (char *)malloc(sizeof(NSString *) * [sqlArguments count]);
    [sqlArguments getObjects:(id *)argList];
    NSString* result = [[[NSString alloc] initWithFormat:aCondition
                                               arguments:argList] autorelease];
    free(argList);
    
    ARWhereStatement *where = [ARWhereStatement statement:result];
    
    if(self.whereStatement){
        ARWhereStatement *currentWhere = self.whereStatement;
        self.whereStatement = [ARWhereStatement concatenateStatement:currentWhere
                                                       withStatement:where
                                                 useLogicalOperation:ARLogicalAnd];
    }else {
        self.whereStatement = where;
    }
    return self;
}

@end
