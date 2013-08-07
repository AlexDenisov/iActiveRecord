//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ActiveRecord;
@class ARConfiguration;

@interface ARDatabaseManager : NSObject
{
    @private
    sqlite3 *database;
}

@property (nonatomic, strong) ARConfiguration *configuration;

- (void)createDatabase;
- (void)clearDatabase;

- (void)createTables;
- (void)createTable:(id)aRecord;
- (void)appendMigrations;

- (void)openConnection;
- (void)closeConnection;

- (NSArray *)tables;
- (NSArray *)columnsForTable:(NSString *)aTableName;

- (NSString *)tableName:(NSString *)modelName;

+ (instancetype)sharedManager;
- (void)applyConfiguration:(ARConfiguration *)configuration;

- (NSNumber *)getLastId:(NSString *)aRecordName;
- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest;
- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest;
- (NSInteger)countOfRecordsWithName:(NSString *)aName;
- (NSInteger)functionResult:(NSString *)anSql;

- (NSInteger)saveRecord:(ActiveRecord *)aRecord;
- (NSInteger)updateRecord:(ActiveRecord *)aRecord;
- (void)dropRecord:(ActiveRecord *)aRecord;
- (BOOL)executeSqlQuery:(const char *)anSqlQuery;

- (void)createIndices;
- (NSArray *)records;

@end
