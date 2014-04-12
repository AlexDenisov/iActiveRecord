//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "class_getSubclasses.h"
#import "sqlite3_unicode.h"
#import "ARColumn_Private.h"
#import "ARSQLBuilder.h"
#import "ARSchemaManager.h"

@implementation ARDatabaseManager

static NSArray *records = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)applyConfiguration:(ARConfiguration *)configuration {
    self.configuration = configuration;
    [self createDatabase];
}

- (void)dealloc {
    [self closeConnection];
}

- (void)createDatabase {
    NSString *databasePath = self.configuration.databasePath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        [self openConnection];
        [self appendMigrations];
        return;
    }
    
    [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
    
    [self openConnection];
    [self createTables];
}

- (void)clearDatabase {
    NSArray *entities =  [self records];
    for (Class Record in entities) {
        [Record performSelector:@selector(dropAllRecords)];
    }
}

- (void)createTables {
    NSArray *entities = [self records];
    for (Class Record in entities) {
        [self createTable:Record];
    }
    [self createIndices];
}

- (void)createTable:(Class)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnCreateTableForRecord:aRecord];
    [self executeSqlQuery:sqlQuery];
}

- (void)appendMigrations {
    if (!self.configuration.isMigrationsEnabled) {
        return;
    }
    
    NSArray *existedTables = [self tables];
    NSArray *existedViews = [self views];
    NSArray *allExisting = [existedViews arrayByAddingObjectsFromArray: existedTables];
    NSArray *describedTables = [self records];
    
    for (Class tableClass in describedTables) {
        NSString *tableName = [tableClass recordName];
        if (![allExisting containsObject:tableName] ) {
            //only create table if there is no table or view for ist
            [self createTable:tableClass];
        } else {

            NSArray *existedColumns = [self columnsForTable:tableName];
            
            NSArray *describedProperties = [tableClass performSelector:@selector(columns)];
            NSMutableArray *describedColumns = [NSMutableArray array];
            
            for (ARColumn *column in describedProperties) {
                [describedColumns addObject:column.columnName];
            }
            
            for (NSString *column in describedColumns) {
                if ([existedColumns containsObject:column]) {
                    continue;
                }
                if([existedViews containsObject: tableName])
                {
                    NSLog(@"'%@' is a view and column '%@' is missing. Cannot auto-migrate view tables !!! You have to adapt the view manually.", tableName, column, nil);
                }

                const char *sql = [ARSQLBuilder sqlOnAddColumn:column toRecord:tableClass];
                [self executeSqlQuery:sql];
            }
        }
    }
    [self createIndices];
}

- (NSArray *)columnsForTable:(NSString *)aTableName {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        
        NSString *sqlString = [NSString stringWithFormat:@"PRAGMA table_info('%@')", aTableName];
        
        sqlite3_stmt *statement;
        
        const char *sqlQuery = [sqlString UTF8String];
        
        if (sqlite3_prepare_v2(database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const unsigned char *pszValue = sqlite3_column_text(statement, 1);
            if (pszValue) {
                [resultArray addObject:[NSString stringWithUTF8String:(const char *)pszValue]];
            }
        }
        
        
    });
    return resultArray;
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *)tables {
    return [self sqliteItemsWithType: @"table"];
}

- (NSArray*) views {
    return [self sqliteItemsWithType: @"view"];
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *) sqliteItemsWithType: (NSString*) type {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [[NSString stringWithFormat: @"select tbl_name from sqlite_master where type='%@' and name not like 'sqlite_%'", type, nil] UTF8String];
        if ( SQLITE_OK != sqlite3_get_table(database,
                                            pszSql,
                                            &results,
                                            &nRows,
                                            &nColumns,
                                            NULL) )
        {
            NSLog( @"Couldn't retrieve data from database: %s", sqlite3_errmsg(database) );
            return;
        }
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        for (int i = 0; i < nRows - 1; i++) {
            for (int j = 0; j < nColumns; j++) {
                int index = (i + 1) * nColumns + j;
                [resultArray addObject:[NSString stringWithUTF8String:results[index]]];
            }
        }
        sqlite3_free_table(results);
    });
    return resultArray;
}

- (void)openConnection {
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_unicode_load();
        if ( SQLITE_OK != sqlite3_open([self.configuration.databasePath UTF8String], &database) ) {
            NSLog( @"Couldn't open database connection: %s", sqlite3_errmsg(database) );
        }
    });
}

- (NSString *)tableName:(NSString *)modelName {
    return modelName;
}

- (void)closeConnection {
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_close(database);
        sqlite3_unicode_free();
    });
}

- (BOOL)executeSqlQuery:(const char *)anSqlQuery {
    __block BOOL result = YES;
    dispatch_sync([self activeRecordQueue], ^{
        if ( SQLITE_OK != sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL) ) {
            NSLog( @"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database) );
            result = NO;
        }
    });
    return result;
}

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        
        sqlite3_stmt *statement;
        
        const char *sqlQuery = [aSqlRequest UTF8String];
        
        if (sqlite3_prepare_v2(database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        Class Record = NSClassFromString(aName);
        BOOL hasColumns = NO;
        NSMutableArray *columns = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int columnsCount = sqlite3_column_count(statement);
            if (columns == nil) {
                columns = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            ActiveRecord *record = [Record new];
            
            for (int columnIndex = 0; columnIndex < columnsCount; columnIndex++) {
                
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, columnIndex)];
               
                if (!hasColumns) {
                    ARColumn* column = [Record performSelector:@selector(columnNamed:)
                                                       withObject:columnName];
                    if(column == nil){
                        /*if working with views, sqlite3_column_name(statement, columnIndex) currently returns fully qualified column names
                        * the follwoing code dissembles the fully qualified name to have only the raw column name itself self for the lookup in the
                        * record columns. Though it returns the correct column.
                        */
                        NSArray* array = [columnName componentsSeparatedByString: @"."];
                        NSString* newColumnName = [array.lastObject stringByReplacingOccurrencesOfString: @"\"" withString: @""];
                        column = [Record performSelector:@selector(columnNamed:)
                                              withObject:newColumnName];
                    }
                    if(column == nil){
                        //our recovery operation for the column name failed
                        sqlite3_finalize(statement);
                        @throw [ARException exceptionWithName: @"ColumnNotFoundInRecord"
                                                       reason: [NSString stringWithFormat: @"Column %@ could not be found in record %@", columnName, [Record recordName],nil  ]
                                                     userInfo: nil];
                    }
                    columns[columnIndex] = column;
                }
                ARColumn *column = columns[columnIndex];
                
                id value = nil;
                
                int columnType = sqlite3_column_type(statement, columnIndex);
                
                switch (columnType) {
                    case SQLITE_INTEGER:
                        value = @( sqlite3_column_int(statement, columnIndex) );
                        break;
                    case SQLITE_FLOAT: {
                        value = @( sqlite3_column_double(statement, columnIndex) );
                    } break;
                    case SQLITE_BLOB: {
                        value = [NSData dataWithBytes:sqlite3_column_blob(statement, columnIndex)
                                               length:sqlite3_column_bytes(statement, columnIndex)];
                    } break;
                    case SQLITE3_TEXT: {
                        value = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex)];
                        if ([column.columnClass isSubclassOfClass:[NSDecimalNumber class]]) {
                            value = [NSDecimalNumber decimalNumberWithString:value];
                        }
                    } break;
                    case SQLITE_NULL: {
                        value = nil;
                    } break;
                    default:
                        NSLog(@"UNKOWN COLUMN TYPE %d", columnType);
                        break;
                }
                [record setValue:value forColumn:column];
            }
            [record resetChanges];
            [resultArray addObject:record];
            hasColumns = YES;
        }
        sqlite3_finalize(statement);
        
    });
    
    return resultArray;
}

- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        sqlite3_stmt *statement;
        
        const char *sqlQuery = [aSqlRequest UTF8String];
        
        if (sqlite3_prepare_v2(database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        BOOL cachesLoaded = NO;
        
        NSMutableDictionary *recordsDictionary;
        
        NSMutableArray *columns = nil;
        Class *recordClasses = NULL;
        NSMutableArray *recordNames = nil;
        NSMutableArray *propertyNames = nil;
        NSString *propertyName = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int columnsCount = sqlite3_column_count(statement);
            if (columns == nil) {
                columns = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            if (!recordClasses) {
                recordClasses = (Class *)malloc(sizeof(Class) * columnsCount);
            }
            
            if (!recordNames) {
                recordNames = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            if (!propertyNames) {
                propertyNames = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            recordsDictionary = [NSMutableDictionary dictionary];
            
            for (int columnIndex = 0; columnIndex < columnsCount; columnIndex++) {
                
                NSString *recordName = nil;
                
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, columnIndex)];
                
                if (!cachesLoaded) {
                    NSArray *splitHeader = [columnName componentsSeparatedByString:@"#"];
                    [recordNames addObject:[splitHeader objectAtIndex:0]];
                    [propertyNames addObject:[splitHeader objectAtIndex:1]];
                    
                    recordClasses[columnIndex] = NSClassFromString([recordNames lastObject]);
                    ARColumn *column = [recordClasses[columnIndex] performSelector:@selector(columnNamed:)
                                                                        withObject:[propertyNames lastObject]];
                    [columns addObject:column];
                }
                recordName = [recordNames objectAtIndex:columnIndex];
                propertyName = [propertyNames objectAtIndex:columnIndex];
                ARColumn *column = columns[columnIndex];
                
                id value = nil;
                
                int columnType = sqlite3_column_type(statement, columnIndex);
                
                switch (columnType) {
                    case SQLITE_INTEGER:
                        value = @( sqlite3_column_int(statement, columnIndex) );
                        break;
                    case SQLITE_FLOAT: {
                        value = @( sqlite3_column_double(statement, columnIndex) );
                    } break;
                    case SQLITE_BLOB: {
                        value = [NSData dataWithBytes:sqlite3_column_blob(statement, columnIndex)
                                               length:sqlite3_column_bytes(statement, columnIndex)];
                    } break;
                    case SQLITE3_TEXT: {
                        value = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex)];
                        if ([column.columnClass isSubclassOfClass:[NSDecimalNumber class]]) {
                            value = [NSDecimalNumber decimalNumberWithString:value];
                        }
                    } break;
                    case SQLITE_NULL: {
                        value = nil;
                    } break;
                    default:
                        NSLog(@"UNKOWN COLUMN TYPE %d", columnType);
                        break;
                }
                ActiveRecord *currentRecord = [recordsDictionary valueForKey:recordName];
                if (currentRecord == nil) {
                    Class Record = recordClasses[columnIndex];
                    currentRecord = [Record new];
                    [recordsDictionary setValue:currentRecord
                                         forKey:recordName];
                }
                
                [currentRecord setValue:value forColumn:column];
            }
            cachesLoaded = YES;
            [resultArray addObject:recordsDictionary];
        }
        sqlite3_finalize(statement);
        
    });
    
    return resultArray;
}

- (NSInteger)countOfRecordsWithName:(NSString *)aName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:
                             @"SELECT count(id) FROM '%@'",
                             [self tableName:aName]];
    return [self functionResult:aSqlRequest];
}

- (NSNumber *)getLastId:(NSString *)aRecordName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:@"select MAX(id) from '%@'", aRecordName];
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
        if ( SQLITE_OK != sqlite3_get_table(database,
                                            pszSql,
                                            &results,
                                            &nRows,
                                            &nColumns,
                                            NULL) )
        {
            NSLog(@"%@", anSql);
            NSLog( @"Couldn't retrieve data from database: %s", sqlite3_errmsg(database) );
            return;
        }
        if (nRows == 0 || nColumns == 0) {
            resId = -1;
        } else {
            resId = [[NSString stringWithUTF8String:results[1]] integerValue];
        }
        
        sqlite3_free_table(results);
    });
    
    return resId;
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
        
        NSString *valueMapping = [@"" stringByPaddingToLength: (columnsCount) * 2 - 1
                                                   withString: @"?,"
                                              startingAtIndex: 0];
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnsCount];
        
        for (ARColumn *column in changedColumns) {
            [columns addObject:[NSString stringWithFormat:@"'%@'", column.columnName]];
        }
        
        NSString *sqlString = [NSString stringWithFormat:
                               @"INSERT INTO '%@'(%@) VALUES(%@)",
                               [aRecord recordName],
                               [columns componentsJoinedByString:@","],
                               valueMapping];
        
        sql = [sqlString UTF8String];

        if(SQLITE_OK != sqlite3_prepare_v2(database, sql, strlen(sql), &stmt, NULL)) {
            NSLog( @"Couldn't save record to database: %s", sqlite3_errmsg(database));
            return;
        }

        int columnIndex = 1;
        for (ARColumn *column in changedColumns) {
            id value = [aRecord valueForColumn:column];
            
            switch (column.columnType) {
                case ARColumnTypeComposite:
//                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
//                        sqlite3_bind_text(stmt, columnIndex, [[value toSql] UTF8String], -1, SQLITE_TRANSIENT);
                        //NOTE: NSNumber must come after NSDecimalNumber because NSDecimalNumber is a
                        //subclass of NSNumber
//                    } else
//                    if ([value isKindOfClass:[NSNumber class]]) {
//                        sqlite3_bind_int(stmt, columnIndex, [value integerValue]);
//                    } else
                    if ([value isKindOfClass:[NSData class]]) {
                        NSData *data = value;
                        sqlite3_bind_blob(stmt, columnIndex, [data bytes], [data length], NULL);
                    } else {
                        NSLog(@"UNKNOWN COLUMN !!1 %@ %@", value, column.columnName);
                    }
                    
                    break;
                default:
                    column.internal->bind(stmt, columnIndex, value);
                    break;
            }
            columnIndex++;
        }

        if(SQLITE_DONE == sqlite3_step(stmt) &&
                SQLITE_OK == sqlite3_finalize(stmt)) {
            result = sqlite3_last_insert_rowid(database);
        } else {
            int error = sqlite3_finalize(stmt);
            NSLog( @"Couldn't save record to database: %s", sqlite3_errmsg(database) );

            switch(error) {
                case SQLITE_CONSTRAINT:
                    //TODO: Code should be added here to detect which column failed and added to model errors. JKW
                    break;
            }
        }
    });
    return result;
}

- (NSInteger)updateRecord:(ActiveRecord *)aRecord {
    aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sqlQuery = [ARSQLBuilder sqlOnUpdateRecord:aRecord];
    if (!sqlQuery) {
        return 0;
    }
    if ([self executeSqlQuery:sqlQuery]) {
        return 1;
    }
    return 0;
}

- (void)dropRecord:(ActiveRecord *)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnDropRecord:aRecord];
    if (!sqlQuery) {
        return;
    }
    [self executeSqlQuery:sqlQuery];
}

- (void)createIndices {
    for (Class record in [self records]) {
        NSArray *indices = [[ARSchemaManager sharedInstance] indicesForRecord:record];
        for (NSString *indexColumn in indices) {
            const char *sqlQuery = [ARSQLBuilder sqlOnCreateIndex:indexColumn
                                                        forRecord:record];
            [self executeSqlQuery:sqlQuery];
        }
    }
}

- (NSArray *)records {
    if (records == nil) {
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
