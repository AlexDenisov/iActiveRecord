//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ActiveRecord;

@interface ARDatabaseManager : NSObject
{
    @private
    sqlite3 *database;
    NSString *dbPath;
    NSString *dbName;
}

+ (void)disableMigrations;

- (void)createDatabase;
- (void)clearDatabase;

- (void)createTables;
- (void)createTable:(id)aRecord;
- (void)addColumn:(NSString *)aColumn onTable:(NSString *)aTable;
- (void)appendMigrations;

- (void)openConnection;
- (void)closeConnection;

- (NSArray *)tables;
- (NSArray *)describedTables;
- (NSArray *)columnsForTable:(NSString *)aTableName;

- (NSString *)tableName:(NSString *)modelName;
- (NSString *)documentsDirectory;
- (NSString *)cachesDirectory;

+ (id)sharedInstance;

- (NSNumber *)insertRecord:(NSString *)aRecordName withSqlQuery:(const char *)anSqlQuery;
- (NSNumber *)getLastId:(NSString *)aRecordName;
- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest;
- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest;
- (NSInteger)countOfRecordsWithName:(NSString *)aName;
- (NSInteger)functionResult:(NSString *)anSql;

- (NSInteger)executeFunction:(const char *)anSqlQuery;

+ (void)registerDatabase:(NSString *)aDatabaseName cachesDirectory:(BOOL)isCache;

- (void)skipBackupAttributeToFile:(NSURL*) url;

//  return new recordId or zero
- (NSInteger)saveRecord:(ActiveRecord *)aRecord;
//  return zero if failure
- (NSInteger)updateRecord:(ActiveRecord *)aRecord;
//  return false if failure
- (void)dropRecord:(ActiveRecord *)aRecord;
- (BOOL)executeSqlQuery:(const char *)anSqlQuery;

- (void)createIndices;
- (NSArray *)records;

@end
 