//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#include <sys/xattr.h>

#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "class_getSubclasses.h"
#import "NSString+quotedString.h"
#import "sqlite3_unicode.h"
#import "ARColumn.h"
#import "ARSQLBuilder.h"
#import "ARSchemaManager.h"

#define DEFAULT_DBNAME @"database"

@implementation ARDatabaseManager

static BOOL useCacheDirectory = YES;
static NSString *databaseName = DEFAULT_DBNAME;
static BOOL migrationsEnabled = YES;

static NSArray *records = nil;

+ (void)registerDatabase:(NSString *)aDatabaseName cachesDirectory:(BOOL)isCache {
    databaseName = [aDatabaseName copy];
    useCacheDirectory = isCache;
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
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
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", [aTableName quotedString]];
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

    });
    return resultArray;
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *)tables {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
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

    });
    return resultArray;
}

- (void)openConnection {
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_unicode_load();
        if(SQLITE_OK != sqlite3_open([dbPath UTF8String], &database)){
            NSLog(@"Couldn't open database connection: %s", sqlite3_errmsg(database));
        }
    });
}

- (NSString *)tableName:(NSString *)modelName {
    return [[NSString stringWithFormat:@"%@", modelName] quotedString];
}

- (void)closeConnection {
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_close(database);
        sqlite3_unicode_free();
    });
}

- (NSNumber *)insertRecord:(NSString *)aRecordName withSqlQuery:(const char *)anSqlQuery {
    [self executeSqlQuery:anSqlQuery];
    return [self getLastId:aRecordName];
}

- (BOOL)executeSqlQuery:(const char *)anSqlQuery {
    __block BOOL result = YES;
    dispatch_sync([self activeRecordQueue], ^{
        if(SQLITE_OK != sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL)){
            NSLog(@"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database));
            result = NO;
        }
    });
    return result;
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
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
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
                        }
                        [record setValue:aValue forColumn:column];
                    }
                }
                [record resetChanges];
                [resultArray addObject:record];
            }
            sqlite3_free_table(results);
        }else
        {
            NSLog(@"%@", aSqlRequest);
            NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }

    });
    
    return resultArray;
}

- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
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
                        }
                    } else {
                        aValue = @"";
                    }
                    
                    id currentRecord = [dictionary valueForKey:recordName];
                    if(currentRecord == nil){
                        currentRecord = [Record new];
                        [dictionary setValue:currentRecord
                                      forKey:recordName];
                    }
                    [currentRecord setValue:aValue
                                  forColumn:column];
                }
                [resultArray addObject:dictionary];
            }
            sqlite3_free_table(results);
        }else
        {
            NSLog(@"%@", aSqlRequest);
            NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }
    });
    
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
    __block NSInteger resId = 0;
    
    dispatch_sync([self activeRecordQueue], ^{
        char **results;
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

    });
    
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
    
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;
    if (!columnsCount) {
        return 0;
    }
    
    
    changedColumns = [aRecord changedColumns];
    columnsCount = changedColumns.count;
    
    __block int result = 0;
    
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_stmt *stmt;
        const char *sql;

        NSString *valueMapping = [@"" stringByPaddingToLength:(columnsCount) * 2 - 1
                                                    withString:@"?,"
                                               startingAtIndex:0];
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnsCount];
        
        for (ARColumn *column in changedColumns){
            [columns addObject:[NSString stringWithFormat:@"'%@'", column.columnName]];
        }
        
        NSString *sqlString = [NSString stringWithFormat:
                               @"INSERT INTO '%@'(%@) VALUES(%@)",
                               [aRecord recordName],
                               [columns componentsJoinedByString:@","],
                               valueMapping];
        
        sql = [sqlString UTF8String];
        
        result = sqlite3_prepare_v2(database, sql, strlen(sql), &stmt, NULL);

        int columnIndex = 1;
        for (ARColumn *column in changedColumns) {
            id value = [aRecord valueForColumn:column];
            
            switch (column.columnType) {
                case ARColumnTypeComposite:
                    if ([value isKindOfClass:[NSString class]]) {
                        sqlite3_bind_text(stmt, columnIndex, [value UTF8String], -1, SQLITE_TRANSIENT);
                    } else if ([value isKindOfClass:[NSDate class]]) {
                        sqlite3_bind_double(stmt, columnIndex, [value timeIntervalSince1970]);
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        sqlite3_bind_int(stmt, columnIndex, [value integerValue]);
                    } else if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        sqlite3_bind_double(stmt, columnIndex, [value doubleValue]);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSData *data = value;
                        sqlite3_bind_blob(stmt, columnIndex, [data bytes], [data length], NULL);
                    } else {
                        NSLog(@"UNKNOWN COLUMN !!1 %@ %@", value, column.columnName);
                    }
                    
                    break;
                case ARColumnTypePrimitiveChar: // BOOL, char
                    sqlite3_bind_int(stmt, columnIndex, [value charValue]);
                    break;
                case ARColumnTypePrimitiveUnsignedChar: // unsigned char
                    sqlite3_bind_int(stmt, columnIndex, [value unsignedCharValue]);
                    break;
                case ARColumnTypePrimitiveShort: // short
                    sqlite3_bind_int(stmt, columnIndex, [value shortValue]);
                    break;
                case ARColumnTypePrimitiveUnsignedShort: // unsigned short
                    sqlite3_bind_int(stmt, columnIndex, [value unsignedShortValue]);
                    break;
                case ARColumnTypePrimitiveInt: // int, NSInteger
                    sqlite3_bind_int(stmt, columnIndex, [value intValue]);
                    break;
                case ARColumnTypePrimitiveUnsignedInt: // uint, NSUinteger
                    sqlite3_bind_int(stmt, columnIndex, [value unsignedIntValue]);
                    break;
                case ARColumnTypePrimitiveLong: // long
                    sqlite3_bind_int(stmt, columnIndex, [value longValue]);
                    break;
                case ARColumnTypePrimitiveUnsignedLong: // unsigned long
                    sqlite3_bind_int(stmt, columnIndex, [value unsignedLongValue]);
                    break;
                case ARColumnTypePrimitiveLongLong: // long long
                    sqlite3_bind_int(stmt, columnIndex, [value longLongValue]);
                    break;
                case ARColumnTypePrimitiveUnsignedLongLong: // unsigned long long
                    sqlite3_bind_int(stmt, columnIndex, [value unsignedLongLongValue]);
                    break;
                case ARColumnTypePrimitiveFloat: // float, CGFloat
                    sqlite3_bind_double(stmt, columnIndex, [value floatValue]);
                    break;
                case ARColumnTypePrimitiveDouble: // double
                    sqlite3_bind_double(stmt, columnIndex, [value doubleValue]);
                    break;
                default:
                    break;
            }
            columnIndex++;
        }
        
        result = sqlite3_step(stmt);
//        NSLog(@"Step: %d", result);
        
        result = sqlite3_finalize(stmt);
//        NSLog(@"Finalize: %d", result);
        
        result = sqlite3_last_insert_rowid(database);
//        NSLog(@"LastInsertRowID: %d", result);
    });
    return result;
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
        records = class_getSubclasses([ActiveRecord class]);
    }
    return records;
}


#pragma mark - GCD support

+ (dispatch_queue_t)activeRecordQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceTokenQueue;
    dispatch_once(&onceTokenQueue, ^{
        queue = dispatch_queue_create("org.okolodev.iactiverecord", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (dispatch_queue_t)activeRecordQueue {
    return [[self class] activeRecordQueue];
}

@end
