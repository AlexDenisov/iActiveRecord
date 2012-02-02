#import "ARDatabaseManager.h"
#import "ActiveRecord.h"
#import "class_getSubclasses.h"

#define DEFAULT_DBNAME @"database"

@implementation ARDatabaseManager

static ARDatabaseManager *instance = nil;

+ (id)sharedInstance {
    if(nil == instance){
        instance = [[ARDatabaseManager alloc] init];
    }
    return instance;
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
        NSLog(@"Created new database");
        [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
        [self openConnection];
        [self appendMigrations];
        return;
    }
    [self openConnection];
    NSLog(@"Database already exists");
}

- (void)appendMigrations {
    NSLog(@"appendMigrations");
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
    return [NSString stringWithFormat:@"AR%@", modelName];
}

- (void)closeConnection {
    sqlite3_close(database);
}

- (void)executeSqlQuery:(const char *)anSqlQuery {
    if(SQLITE_OK == sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL)){
        NSLog(@"Query '%s' executed", anSqlQuery);
    }else{
        NSLog(@"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database));
    }
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest{
    NSLog(@"Start request: %@", aSqlRequest);
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
        }
        sqlite3_free_table(results);
    }else
    {
      NSLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    return resultArray;
}

- (NSArray *)allRecordsWithName:(NSString *)aName {
    NSString *sql = [NSString stringWithFormat:@"select * from %@", [self tableName:aName]];
    return [self allRecordsWithName:aName withSql:sql];
}

- (id)findRecord:(NSString *)aName byId:(NSNumber *)anId {
    if(nil == anId){
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where id = %d limit 1", [self tableName:aName], [anId integerValue]];
    NSArray *records = [self allRecordsWithName:aName withSql:sql];
    return [records count] ? [records objectAtIndex:0] : nil;
}

- (NSArray *)findRecords:(NSString *)aName byId:(NSNumber *)anId {
    if(nil == anId){
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where id = %d", [self tableName:aName], [anId integerValue]];
    NSArray *records = [self allRecordsWithName:aName withSql:sql];
    return records;
}

- (NSArray *)allRecordsWithName:(NSString *)aName whereKey:(NSString *)aKey hasValue:(id)aValue{
    NSLog(@"%@", [aValue toSql]);
    NSString *sql = [NSString stringWithFormat:
                     @"select * from %@ where %@ = %@", 
                     [self tableName:aName], 
                     aKey, 
                     [aValue toSql]];
    NSArray *records = [self allRecordsWithName:aName withSql:sql];
    return records;
}

@end
