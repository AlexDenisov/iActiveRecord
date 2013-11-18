//
//  ARLazyFetcher.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARLazyFetcher.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"
#import "ARColumn.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARLazyFetcher_Private.h"

@implementation ARLazyFetcher

@synthesize whereStatement;

- (instancetype)init {
    self = [super init];
    if (self) {
        limit = nil;
        offset = nil;
        sqlRequest = nil;
        orderByConditions = nil;
        useJoin = NO;
        useRandomOrder = NO;
    }
    return self;
}

- (instancetype)initWithRecord:(Class)aRecord {
    self = [self init];
    recordClass = aRecord;
    return self;
}

- (instancetype)initWithRecord:(Class)aRecord withInitialSql:(NSString *)anInitialSql {
    self = [self initWithRecord:aRecord];
    if (self) {
        sqlRequest = [anInitialSql copy];
    }
    return self;
}

#pragma mark - Building SQL request

- (NSSet *)fieldsOfRecord:(ActiveRecord *)aRecord {
    NSMutableSet *fields = [NSMutableSet set];
    if (onlyFields) {
        [fields addObjectsFromArray:[onlyFields allObjects]];
    } else {
        NSArray *columns = [aRecord columns];
        for (ARColumn *column in columns) {
            [fields addObject:column.columnName];
        }
    }
    if (exceptFields) {
        for (NSString *field in exceptFields) {
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
    if (whereStatement) {
        [statement appendFormat:@" WHERE (%@) ", self.whereStatement];
    }
    return statement;
}

- (NSString *)createOrderbyStatement {
    NSMutableString *statement = [NSMutableString string];
    if (useRandomOrder) {
        [statement appendFormat:@" ORDER BY RANDOM() "];
    } else if (!orderByConditions) {
        return statement;
    }
    [statement appendFormat:@" ORDER BY "];
    for (NSString *key in [orderByConditions allKeys]) {
        NSString *order = [[orderByConditions valueForKey:key] boolValue] ? @"ASC" : @"DESC";
        [statement appendFormat:
         @" \"%@\".\"%@\" %@ ,",
         [recordClass performSelector:@selector(recordName)], key, order];
    }
    [statement replaceCharactersInRange:NSMakeRange(statement.length - 1, 1) withString:@""];
    return statement;
}

- (NSString *)createLimitOffsetStatement {
    NSMutableString *statement = [NSMutableString string];
    NSInteger limitNum = -1;
    if (limit) {
        limitNum = limit.integerValue;
    }
    [statement appendFormat:@" LIMIT %d ", limitNum];
    if (offset) {
        [statement appendFormat:@" OFFSET %d ", offset.integerValue];
    }
    return statement;
}

- (NSString *)createJoinedSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for (NSString *field in [self fieldsOfRecord : recordClass]) {
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\" AS '%@#%@'",
                     [recordClass performSelector:@selector(recordName)],
                     field,
                     [recordClass.class description], // use the class name here, since the class is looked up when records are loaded
                     field];
        [fields addObject:fieldname];
    }

    for (NSString *field in [self fieldsOfRecord : joinClass]) {
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\" AS '%@#%@'",
                     [joinClass performSelector:@selector(recordName)],
                     field,
                     [joinClass.class description],  // use the class name here, since the class is looked up when records are loaded

                     field];
        [fields addObject:fieldname];
    }

    [statement appendFormat:@"%@ FROM \"%@\" ",
     [fields componentsJoinedByString:@","],
     [recordClass performSelector:@selector(recordName)]];
    return statement;
}

- (NSString *)createSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for (NSString *field in [self recordFields]) {
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\"",
                     [recordClass performSelector:@selector(recordName)],
                     field];
        [fields addObject:fieldname];
    }
    [statement appendFormat:@"%@ FROM \"%@\" ",
     [fields componentsJoinedByString:@","],
     [recordClass performSelector:@selector(recordName)]];
    return statement;
}

- (NSString *)createJoinStatement {
    NSMutableString *statement = [NSMutableString string];
    if (!useJoin) {
        return statement;
    }
    NSString *join = joinString(joinType);
    NSString *joinTable = [joinClass performSelector:@selector(recordName)];
    NSString *selfTable = [recordClass performSelector:@selector(recordName)];
    [statement appendFormat:
     @" %@ JOIN \"%@\" ON \"%@\".\"%@\" = \"%@\".\"%@\" ",
     join,
     joinTable,
     selfTable, recordField,
     joinTable, joinField];
    return statement;
}

#pragma mark - Helpers

- (ARLazyFetcher *)offset:(NSInteger)anOffset {
    offset =  @(anOffset);
    return self;
}

- (ARLazyFetcher *)limit:(NSInteger)aLimit {
    limit = @(aLimit);
    return self;
}

#pragma mark - OrderBy

- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending {
    if (orderByConditions == nil) {
        orderByConditions = [NSMutableDictionary new];
    }
    NSNumber *ascending = [NSNumber numberWithBool:isAscending];
    [orderByConditions setValue:ascending forKey:aField];
    return self;
}

- (ARLazyFetcher *)orderBy:(NSString *)aField {
    return [self orderBy:aField ascending:YES];
}

- (ARLazyFetcher *)orderByRandom {
    useRandomOrder = YES;
    return self;
}

#pragma mark - Select

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... {
    if (!onlyFields) {
        onlyFields = [NSMutableSet new];
    }
    [onlyFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while ( (field = va_arg(args, NSString *)) ) {
        [onlyFields addObject:field];
    }
    va_end(args);
    return self;
}

- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... {
    if (exceptFields == nil) {
        exceptFields = [NSMutableSet new];
    }
    [exceptFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while ( (field = va_arg(args, NSString *)) ) {
        [exceptFields addObject:field];
    }
    va_end(args);
    return self;
}

#pragma mark - Joins

- (ARLazyFetcher *)join:(Class)aJoinRecord {

    NSString *_recordField = @"id";
    NSString *_joinField = [NSString stringWithFormat:@"%@Id",
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
    recordField = [aFirstField copy];
    joinField = [aSecondField copy];
    useJoin = YES;
    return self;
}

#pragma mark - Immediately fetch

- (NSArray *)fetchRecords {
    [self buildSql];
    return [[ARDatabaseManager sharedManager] allRecordsWithName:[recordClass description]
                                                          withSql:sqlRequest];
}

- (NSArray *)fetchJoinedRecords {
    if (!useJoin) {
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
    return [[ARDatabaseManager sharedManager] joinedRecordsWithSql:sql];
}

- (NSInteger)count {
    NSMutableString *sql = [NSMutableString string];

    NSString *select = [NSString stringWithFormat:@"SELECT count(*) FROM \"%@\" ",
                        [recordClass performSelector:@selector(recordName)]];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];
    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    return [[ARDatabaseManager sharedManager] functionResult:sql];
}

- (ARLazyFetcher *)where:(NSString *)aCondition, ...{
    va_list args;
    NSMutableArray *sqlArguments = [NSMutableArray array];
    NSString *argument = nil;
    
    va_start(args, aCondition);
    id value = nil;
    while ( (value = va_arg(args, id)) ) {
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            argument = [value performSelector:@selector(toSql)];
        } else {
            if ([value respondsToSelector:@selector(toSql)]) {
                value = [value performSelector:@selector(toSql)];
            }
            argument = [NSString stringWithFormat:@"\"%@\"", value];
        }
        [sqlArguments addObject:argument];
    }
    va_end(args);

    NSRange range = NSMakeRange(0, [sqlArguments count]);
    NSMutableData * data = [NSMutableData dataWithLength:sizeof(id) * [sqlArguments count]];
    [sqlArguments getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
    NSString * result = [[NSString alloc] initWithFormat:aCondition
                                               arguments:data.mutableBytes];

    if (!self.whereStatement) {
        self.whereStatement = [[NSMutableString alloc] initWithString:result];
    } else {
        self.whereStatement = [NSMutableString stringWithFormat:@"%@AND %@", self.whereStatement, result];
    }
    return self;
}

@end
