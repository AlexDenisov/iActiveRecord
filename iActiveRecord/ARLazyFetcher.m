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
        whereConditions = nil;
        orderByConditions = nil;
    }
    return self;
}

- (id)initWithRecord:(Class)aRecord
{
    self = [self init];
    record = aRecord;
    return self;
}

- (void)dealloc {
    [orderByConditions release];
    [whereConditions release];
    [sqlRequest release];
    [limit release];
    [offset release];
    [super dealloc];
}

- (void)buildSql {
    NSString *tableName = [record performSelector:@selector(tableName)];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    
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

- (ARLazyFetcher *)whereField:(NSString *)aField hasValue:(id)aValue {
    if(whereConditions == nil){
        whereConditions = [NSMutableDictionary new];
    }
    [whereConditions setValue:aValue
                       forKey:aField];
    return self;
}

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

- (NSArray *)fetchRecords {
    [self buildSql];
    NSLog(@"SQLRequest %@", sqlRequest);
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:[record description]
                                                          withSql:sqlRequest];
}

@end
