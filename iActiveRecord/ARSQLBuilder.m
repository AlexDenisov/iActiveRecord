//
//  ARSQLBuilder.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARSQLBuilder.h"
#import "ActiveRecord_Private.h"
#import "ARColumn_Private.h"
#import "NSString+quotedString.h"

@implementation ARSQLBuilder

+ (const char *)sqlOnSaveRecord:(ActiveRecord *)aRecord {
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;
    if(columnsCount == 0){
        return NULL;
    }
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnsCount];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:columnsCount];
    NSEnumerator *columnsIterator = [changedColumns objectEnumerator];
    ARColumn *column = nil;
    while(column = [columnsIterator nextObject]){
        [columns addObject:[column.columnName quotedString]];
        NSString *value = [[column sqlValueForRecord:aRecord] quotedString];
        [values addObject:value];
    }
    NSString *sqlString = [NSString stringWithFormat:
                           @"INSERT INTO %@(%@) VALUES(%@)",
                           [[aRecord recordName] quotedString],
                           [columns componentsJoinedByString:@","],
                           [values componentsJoinedByString:@","]];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnUpdateRecord:(ActiveRecord *)aRecord {
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;
    if(columnsCount == 0){
        return NULL;
    }
    NSMutableArray *columnValues = [NSMutableArray arrayWithCapacity:columnsCount];
    NSEnumerator *columnsIterator = [changedColumns objectEnumerator];
    for(int index = 0;index<columnsCount;index++){
        ARColumn *column = [columnsIterator nextObject];
        NSString *updater = [NSString stringWithFormat:
                             @"%@=%@",
                             [column.columnName quotedString],
                             [[column sqlValueForRecord:aRecord] quotedString]];
        [columnValues addObject:updater];
    }
    NSString *sqlString = [NSString stringWithFormat:
                           @"UPDATE %@ SET %@ WHERE id = %@",
                           [[aRecord recordName] quotedString],
                           [columnValues componentsJoinedByString:@","],
                           aRecord.id];
    return [sqlString UTF8String];
}

@end
