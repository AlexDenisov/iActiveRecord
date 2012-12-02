//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "class_getSubclasses.h"
#import "NSString+quotedString.h"
#include <sys/xattr.h>
#import "sqlite3_unicode.h"
#import "ARColumn.h"
#import "ARSQLBuilder.h"
#import "ARSchemaManager.h"

#define DEFAULT_DBNAME @"database"

@implementation ARDatabaseManager

static ARDatabaseManager *instance = nil;
static BOOL useCacheDirectory = YES;
static NSString *databaseName = DEFAULT_DBNAME;
static BOOL migrationsEnabled = YES;

static NSArray *records = nil;

+ (void)registerDatabase:(NSString *)aDatabaseName cachesDirectory:(BOOL)isCache {
    databaseName = [aDatabaseName copy];
    useCacheDirectory = isCache;
}

+ (id)sharedInstance {
    @synchronized(self){
        if(nil == instance){
            instance = [[ARDatabaseManager alloc] init];
        }
        return instance;
    }    
}

- (id)init {
    self = [super init];
    if(nil != self){
#ifdef UNIT_TEST
        dbName = [[NSString alloc] initWithFormat:@"%@-test.sqlite", databaseName];
#else
        dbName = [[NSString alloc] initWithFormat:@"%@.sqlite", databaseName];
#endif
        NSString *storageDirectory = useCacheDirectory ? [self cachesDirectory] : [self documentsDirectory];
        dbPath = [[NSString alloc] initWithFormat:@"%@/%@", storageDirectory, dbName];
        NSLog(@"%@", dbPath);
        [self createDatabase];
    }
    return self;
}

- (void)dealloc{
    [self closeConnection];
    [dbName release];
    [dbPath release];
    [super dealloc];
}

- (void)createDatabase {
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
        [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
        if(!useCacheDirectory){
            [self skipBackupAttributeToFile:[NSURL fileURLWithPath:dbPath]];
        }
        [self openConnection];
        [self createTables];
        return;
    }
    [self openConnection];
    [self appendMigrations];
}

- (void)clearDatabase {
    NSArray *entities =  [self records];
    for(Class Record in entities){
        [Record performSelector:@selector(dropAllRecords)];
    }
}

- (void)createTables {
    NSArray *entities = [self records];
    for(Class Record in entities){
        [self createTable:Record];
    }
    [self createIndices];
}

- (void)createTable:(Class)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnCreateTableForRecord:aRecord];
    [self executeSqlQuery:sqlQuery];
}

- (void)appendMigrations {
    if(!migrationsEnabled){
        return;
    }
    NSArray *existedTables = [self tables];
    NSArray *describedTables = [self describedTables];
    for(NSString *table in describedTables){
        if(![existedTables containsObject:table]){
            [self createTable:NSClassFromString(table)];
        }else{
            Class Record = NSClassFromString(table);
            NSArray *existedColumns = [self columnsForTable:table];
            
            NSArray *describedProperties = [Record performSelector:@selector(columns)];
            NSMutableArray *describedColumns = [NSMutableArray array];
            for(ARColumn *column in describedProperties){
                [describedColumns addObject:column.columnName];
            }
            for(NSString *column in describedColumns){
                if(![existedColumns containsObject:column]){
                    const char *sql = (const char *)[ARSQLBuilder sqlOnAddColumn:column
                                                                        toRecord:Record];
//                    const char *sql = (const char *)[Record performSelector:@selector(sqlOnAddColumn:) 
//                                                                 withObject:column];
                    [self executeSqlQuery:sql];
                }
            }
        }
    }
    [self createIndices];
}

- (void)addColumn:(NSString *)aColumn onTable:(NSString *)aTable {
    
}

- (NSArray *)describedTables {
    NSArray *entities = [self records];
    NSMutableArray *tables = [NSMutableArray arrayWithCapacity:entities.count];
    for(Class record in entities){
        [tables addObject:NSStringFromClass(record)];
    }
    return tables;
}

- (NSArray *)columnsForTable:(NSString *)aTableName {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", [aTableName quotedString]];
    NSMutableArray *resultArray = nil;
    char **results;
    int nRows;
    int nColumns;
    const char *pszSql = [sql UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        for(int i=0;i<nRows-1;i++){
            int index = (i + 1)*nColumns + 1;
            const char *pszValue = results[index];
            if(pszValue){
                [resultArray addObject:[NSString stringWithUTF8String:pszValue]];
            }
        }
        sqlite3_free_table(results);
    }else
    {
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resultArray;
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *)tables {
    NSMutableArray *resultArray = nil;
    char **results;
    int nRows;
    int nColumns;
    const char *pszSql = [@"select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'" UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        for(int i=0;i<nRows-1;i++){
            for(int j=0;j<nColumns;j++){
                int index = (i+1)*nColumns + j;
                [resultArray addObject:[NSString stringWithUTF8String:results[index]]];
            }
        }
        sqlite3_free_table(results);
    }else
    {
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resultArray;
}

- (void)openConnection {
    sqlite3_unicode_load();
    if(SQLITE_OK != sqlite3_open([dbPath UTF8String], &database)){
        NSLog(@"Couldn't open database connection: %s", sqlite3_errmsg(database));
    }
}

- (NSString *)tableName:(NSString *)modelName {
    return [[NSString stringWithFormat:@"%@", modelName] quotedString];
}

- (void)closeConnection {
    sqlite3_close(database);
    sqlite3_unicode_free();
}

- (NSNumber *)insertRecord:(NSString *)aRecordName withSqlQuery:(const char *)anSqlQuery {
    [self executeSqlQuery:anSqlQuery];
    return [self getLastId:aRecordName];
}

- (BOOL)executeSqlQuery:(const char *)anSqlQuery {
    if(SQLITE_OK != sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL)){
        NSLog(@"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}
 
- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSString *)cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest{
    NSMutableArray *resultArray = nil;
    NSString *propertyName;
    id aValue;
    Class Record;
    char **results;
    int nRows;
    int nColumns;
    const char *pszSql = [aSqlRequest UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        Record = NSClassFromString(aName);
        for(int i=0;i<nRows-1;i++){
            id record = [Record new];
            for(int j=0;j<nColumns;j++){
                propertyName = [NSString stringWithUTF8String:results[j]];
                int index = (i+1)*nColumns + j;
                const char *pszValue = results[index];
                ARColumn *column = [Record performSelector:@selector(columnNamed:) 
                                                withObject:propertyName];
                if(pszValue){
                    NSString *sqlData = [NSString stringWithUTF8String:pszValue];
                    if (column.columnClass) {
                        aValue = [column.columnClass performSelector:@selector(fromSql:)
                                                          withObject:sqlData];
                    } else {
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        [formatter setNumberStyle:NSNumberFormatterNoStyle];
                        aValue = [formatter numberFromString:sqlData];
                        [formatter release];
                    }
                    [record setValue:aValue forColumn:column];
                }
            }
            [record resetChanges];
            [resultArray addObject:record];
            [record release];
        }
        sqlite3_free_table(results);
    }else
    {
        NSLog(@"%@", aSqlRequest);
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resultArray;
}

- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest {
    NSMutableArray *resultArray = nil;
    NSString *propertyName;
    NSString *header;
    id aValue;
    char **results;
    int nRows;
    int nColumns;
    const char *pszSql = [aSqlRequest UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        for(int i=0;i<nRows-1;i++){
            NSMutableDictionary *dictionary = [NSMutableDictionary new];
            NSString *recordName = nil;
            for(int j=0;j<nColumns;j++){
                header = [NSString stringWithUTF8String:results[j]];
                
                recordName = [[header componentsSeparatedByString:@"#"] objectAtIndex:0];
                propertyName = [[header componentsSeparatedByString:@"#"] objectAtIndex:1];
                
                Class Record = NSClassFromString(recordName);
                
                int index = (i+1)*nColumns + j;
                const char *pszValue = results[index];
                ARColumn *column = [Record performSelector:@selector(columnNamed:) 
                                                withObject:propertyName];
                if(pszValue){
                    NSString *sqlData = [NSString stringWithUTF8String:pszValue];
                    if (column.columnClass) {
                        aValue = [column.columnClass performSelector:@selector(fromSql:)
                                                          withObject:sqlData];
                    } else {
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        [formatter setNumberStyle:NSNumberFormatterNoStyle];
                        aValue = [formatter numberFromString:sqlData];
                        [formatter release];
                    }
                } else {
                    aValue = @"";
                }

                id currentRecord = [dictionary valueForKey:recordName];
                if(currentRecord == nil){
                    currentRecord = [[Record new] autorelease];
                    [dictionary setValue:currentRecord
                                  forKey:recordName];
                }
                [currentRecord setValue:aValue
                              forColumn:column];
            }
            [resultArray addObject:dictionary];
            [dictionary release];
        }
        sqlite3_free_table(results);
    }else
    {
        NSLog(@"%@", aSqlRequest);
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resultArray;
}

- (NSInteger)countOfRecordsWithName:(NSString *)aName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:
                             @"SELECT count(id) FROM %@", 
                             [self tableName:aName]];
    return [self functionResult:aSqlRequest];
}

- (NSNumber *)getLastId:(NSString *)aRecordName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:@"select MAX(id) from %@", 
                             [aRecordName quotedString]];
    NSInteger res = [self functionResult:aSqlRequest];
    return [NSNumber numberWithInt:res];
}

- (NSInteger)functionResult:(NSString *)anSql {
#warning remove
    char **results;
    NSInteger resId = 0;
    int nRows;
    int nColumns;
    const char *pszSql = [anSql UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        if(nRows == 0 || nColumns == 0){
            resId = -1;
        }else{
            resId = [[NSString stringWithUTF8String:results[1]] integerValue];
        }

        sqlite3_free_table(results);
    }else
    {
        NSLog(@"%@", anSql);
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resId;
}

- (void)skipBackupAttributeToFile:(NSURL *)url {
    u_int8_t b = 1;
    setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

+ (void)disableMigrations {
    migrationsEnabled = NO;
}

- (NSInteger)saveRecord:(ActiveRecord *)aRecord {
    aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sqlQuery = [ARSQLBuilder sqlOnSaveRecord:aRecord];
    if(sqlQuery){
        if([self executeSqlQuery:sqlQuery]){
            return sqlite3_last_insert_rowid(database);
        }
    }
    return 0;
}

- (NSInteger)updateRecord:(ActiveRecord *)aRecord {
    aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sqlQuery = [ARSQLBuilder sqlOnUpdateRecord:aRecord];
    if(sqlQuery){
        if([self executeSqlQuery:sqlQuery]){
            return 1;
        }
    }
    return 0;
}

- (void)dropRecord:(ActiveRecord *)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnDropRecord:aRecord];
    if(sqlQuery){
        [self executeSqlQuery:sqlQuery];
    }
}

- (NSInteger)executeFunction:(const char *)anSqlQuery {
#warning implement
    return 0;
}

- (void)createIndices {
    for(Class record in [self records]){
        NSArray *indices = [[ARSchemaManager sharedInstance] indicesForRecord:record];
        for(NSString *indexColumn in indices){
            const char *sqlQuery = [ARSQLBuilder sqlOnCreateIndex:indexColumn
                                                        forRecord:record];
            [self executeSqlQuery:sqlQuery];
        }
    }
}

- (NSArray *)records {
    if(records == nil){
        records = [class_getSubclasses([ActiveRecord class]) retain];
    }
    return records;
}

@end
