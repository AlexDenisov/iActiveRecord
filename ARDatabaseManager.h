#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ARDatabaseManager : NSObject
{
  sqlite3 *database;
  NSString *dbPath;
  NSString *dbName;
}

- (void)createDatabase;
- (void)openConnection;
- (void)closeConnection;
- (NSString *)tableName:(NSString *)modelName;

+ (id)sharedInstance;

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest;
- (NSArray *)allRecordsWithName:(NSString *)aName;
- (id)findRecord:(NSString *)aRecordName byId:(NSNumber *)anId;

@end
