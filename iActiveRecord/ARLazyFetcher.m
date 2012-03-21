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
    [sqlRequest release];
    [limit release];
    [offset release];
    [super dealloc];
}

- (void)buildSql {
    NSString *tableName = [record performSelector:@selector(tableName)];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ ", tableName];
    if(offset){
        [sql appendFormat:@" offset = %d ", offset.integerValue];
    }
    if(limit){
        [sql appendFormat:@" limit = %d", offset.integerValue];
    }
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

- (NSArray *)fetchRecords {
    [self buildSql];
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:[record description]
                                                          withSql:sqlRequest];
}

@end
