#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ARDatabaseManager : NSObject
{
    sqlite3 *database;
    NSString *dbPath;
    NSString *dbName;
}

- (void)createDatabase;
- (void)appendMigrations;
- (void)openConnection;
- (void)closeConnection;
- (NSString *)tableName:(NSString *)modelName;
- (NSString *)documentsDirectory;

+ (id)sharedInstance;

- (void)executeSqlQuery:(const char *)anSqlQuery;
- (NSArray *)allRecordsWithName:(NSString *)aName whereKey:(NSString *)aKey hasValue:(id)aValue;
- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest;
- (NSArray *)allRecordsWithName:(NSString *)aName;
- (NSArray *)findRecords:(NSString *)aRecordName byId:(NSNumber *)anId;
- (id)findRecord:(NSString *)aRecordName byId:(NSNumber *)anId;

@end
