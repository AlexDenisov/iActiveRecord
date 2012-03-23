//
//  ARArray.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARLazyFetcher.h"
#import "ARDatabaseManager.h"

@implementation ARLazyFetcher

- (id)init {
    self = [super init];
    if(nil != self){
        limit = nil;
        offset = nil;
        sqlRequest = nil;
        whereHasConditions = nil;
        whereInConditions = nil;
        whereNotInConditions = nil;
        orderByConditions = nil;
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
    [orderByConditions release];
    [whereInConditions release];
    [whereHasConditions release];
    [whereNotInConditions release];
    [sqlRequest release];
    [limit release];
    [offset release];
    [super dealloc];
}

- (void)buildSql {
    NSMutableString *sql = nil;
    if(sqlRequest == nil){
        NSString *tableName = [recordClass performSelector:@selector(tableName)];
        sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    }else{
        sql = [NSMutableString stringWithString:sqlRequest];
    }
    
    if(orderByConditions){
        [sql appendFormat:@" ORDER BY "];
        for(NSString *key in [orderByConditions allKeys]){
            NSString *order = [[orderByConditions valueForKey:key] boolValue] ? @"ASC" : @"DESC";
            [sql appendFormat:@" %@ %@ ,", key, order];
        }
        [sql replaceCharactersInRange:NSMakeRange(sql.length - 1, 1) withString:@""];
    }
    
    NSInteger limitNum = -1;
    if(limit){
        limitNum = limit.integerValue;
    }
    [sql appendFormat:@" LIMIT %d ", limitNum];
    if(offset){
        [sql appendFormat:@" OFFSET %d ", offset.integerValue];
    }
    NSLog(@"LazyRequest: %@", sql);
    sqlRequest = [sql copy];
}

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
- (ARLazyFetcher *)whereField:(NSString *)aField hasValue:(id)aValue {
    if(whereHasConditions == nil){
        whereHasConditions = [NSMutableDictionary new];
    }
    [whereHasConditions setValue:aValue
                       forKey:aField];
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues {
    return self;
}

- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues {
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

#pragma mark - Immediately fetch

- (NSArray *)fetchRecords {
    [self buildSql];
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:[recordClass description]
                                                          withSql:sqlRequest];
}

@end
