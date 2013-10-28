//
//  ARSQLBuilder.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARSQLBuilder.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"

@implementation ARSQLBuilder

+ (const char *)sqlOnUpdateRecord:(ActiveRecord *)aRecord {
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;
    if (columnsCount == 0) {
        return NULL;
    }
    NSMutableArray *columnValues = [NSMutableArray arrayWithCapacity:columnsCount];
    NSEnumerator *columnsIterator = [changedColumns objectEnumerator];
    for (int index = 0; index < columnsCount; index++) {
        ARColumn *column = [columnsIterator nextObject];
        NSString *value = [column sqlValueForRecord:aRecord];
        NSString *updater = [NSString stringWithFormat:
                             @"\"%@\"=\"%@\"",
                             column.columnName,
                             [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""]];
        [columnValues addObject:updater];
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ WHERE id = %@",
                           [aRecord recordName],
                           [columnValues componentsJoinedByString:@","],
                           aRecord.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnDropRecord:(ActiveRecord *)aRecord {
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE id = %@",
                           [aRecord recordName], aRecord.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnCreateTableForRecord:(Class)aRecord {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:
                                  @"CREATE TABLE \"%@\"(id integer primary key unique",
                                  [aRecord recordName]];
    for (ARColumn *column in [aRecord columns]) {
        if (![column.columnName isEqualToString:@"id"]) {
            [sqlString appendFormat:@",\"%@\" %s",
             column.columnName, [column sqlType]];
        }
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnAddColumn:(NSString *)aColumnName toRecord:(Class)aRecord {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:
                                  @"ALTER TABLE \"%@\" ADD COLUMN ",
                                  [aRecord recordName]];
    ARColumn *column = [aRecord columnNamed:aColumnName];
    [sqlString appendFormat:@"\"%@\" %s",
     aColumnName, [column sqlType]];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnCreateIndex:(NSString *)aColumnName forRecord:(ActiveRecord *)aRecord {
    NSString *sqlString = [NSString stringWithFormat:
                           @"CREATE UNIQUE INDEX IF NOT EXISTS index_%@ ON \"%@\" (\"%@\")",
                           aColumnName,
                           [aRecord recordName],
                           aColumnName];
    return [sqlString UTF8String];
}

@end
