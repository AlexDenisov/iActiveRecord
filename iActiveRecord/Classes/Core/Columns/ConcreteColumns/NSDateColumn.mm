//
// Created by Alex Denisov on 08.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "NSDateColumn.h"

namespace AR {

bool NSDateColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
{
return sqlite3_bind_double(statement, columnIndex, [value timeIntervalSince1970]) == SQLITE_OK;
}

const char *NSDateColumn::sqlType(void) const {
return "real";
}

NSString *NSDateColumn::sqlValueFromRecord(ActiveRecord *record) const
{
NSDate *value = objc_getAssociatedObject(record, this->columnKey());
if(value == nil) return @"null";
NSTimeInterval time = [value timeIntervalSince1970];
return [NSString stringWithFormat:@"%f", time];
}

NSDate *__strong NSDateColumn::toColumnType(id value) const
{
if([value isKindOfClass:[NSDate class]])
            return [NSDate dateWithTimeIntervalSince1970: [value timeIntervalSince1970]];
        else if([value isKindOfClass:[NSNumber class]])
            return [NSDate dateWithTimeIntervalSince1970: [value doubleValue]];
        return nil;
    }

    id NSDateColumn::toObjCObject(NSDate *value) const
    {
        return value;
    }
};
