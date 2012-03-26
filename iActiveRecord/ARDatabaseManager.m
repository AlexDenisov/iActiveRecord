//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARDatabaseManager.h"
#import "ActiveRecord.h"
#import "class_getSubclasses.h"
#import "NSString+quotedString.h"

#if UNIT_TEST
#define DEFAULT_DBNAME @"database"
#else
#define DEFAULT_DBNAME @"database-test"
#endif

@implementation ARDatabaseManager

static ARDatabaseManager *instance = nil;

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
        dbName = [[NSString alloc] initWithFormat:@"%@.sqlite", DEFAULT_DBNAME];
        dbPath = [[NSString alloc] initWithFormat:@"%@/%@", [self documentsDirectory], dbName];
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
        [self openConnection];
        [self appendMigrations];
        return;
    }
    [self openConnection];
}

- (void)clearDatabase {
    NSArray *entities = class_getSubclasses([ActiveRecord class]);
    for(Class Record in entities){
        const char *sqlQuery = (const char *)[Record performSelector:@selector(sqlOnDeleteAll)];
        [self executeSqlQuery:sqlQuery];
    }
}

- (void)appendMigrations {
    NSArray *entities = class_getSubclasses([ActiveRecord class]);
    for(Class Record in entities){
        const char *sqlQuery = (const char *)[Record performSelector:@selector(sqlOnCreate)];
        [self executeSqlQuery:sqlQuery];
    }
}

- (void)openConnection {
    if(SQLITE_OK != sqlite3_open([dbPath UTF8String], &database)){
        NSLog(@"Couldn't open database connection: %s", sqlite3_errmsg(database));
    }
}

- (NSString *)tableName:(NSString *)modelName {
    return [[NSString stringWithFormat:@"%@", modelName] quotedString];
}

- (void)closeConnection {
    sqlite3_close(database);
}

- (NSNumber *)insertRecord:(NSString *)aRecordName withSqlQuery:(const char *)anSqlQuery {
    [self executeSqlQuery:anSqlQuery];
    return [self getLastId:aRecordName];
}

- (void)executeSqlQuery:(const char *)anSqlQuery {
    if(SQLITE_OK != sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL)){
        
        NSLog(@"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database));
    }
}
 
- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
            id record = [Record newRecord];
            for(int j=0;j<nColumns;j++){
                propertyName = [NSString stringWithUTF8String:results[j]];
                int index = (i+1)*nColumns + j;
                const char *pszValue = results[index];
                
                if(pszValue){
                    NSString *propertyClassName = [Record 
                                                   performSelector:@selector(propertyClassNameWithPropertyName:) 
                                                   withObject:propertyName];
                    Class propertyClass = NSClassFromString(propertyClassName);
                    NSString *sqlData = [NSString stringWithUTF8String:pszValue];
                    aValue = [propertyClass performSelector:@selector(fromSql:) 
                                                 withObject:sqlData];
                }else{
                    aValue = @"";
                }
                [record setValue:aValue forKey:propertyName];
            }
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

- (NSInteger)countOfRecordsWithName:(NSString *)aName {
    NSString *aSqlRequest = [NSString stringWithFormat:
                             @"SELECT count(id) FROM %@", 
                             [self tableName:aName]];
    return [self functionResult:aSqlRequest];
}

- (NSNumber *)getLastId:(NSString *)aRecordName {
    NSString *aSqlRequest = [NSString stringWithFormat:@"select MAX(id) from %@", 
                             [aRecordName quotedString]];
    NSInteger res = [self functionResult:aSqlRequest];
    return [NSNumber numberWithInt:res];
}

- (NSInteger)functionResult:(NSString *)anSql {
    char **results;
    NSInteger resId;
    const char *pszSql = [anSql UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      NULL,
                                      NULL,
                                      NULL))
    {
        resId = [[NSString stringWithUTF8String:results[1]] integerValue];
        sqlite3_free_table(results);
    }else
    {
        NSLog(@"%@", anSql);
        NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resId;
}

@end
