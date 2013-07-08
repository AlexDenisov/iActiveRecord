//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "LongLongColumn.h"

namespace AR {

    bool LongLongColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value longLongValue]) == SQLITE_OK;
    }

    const char *LongLongColumn::sqlType(void) const {
        return "integer";
    }

    NSString *LongLongColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    long long LongLongColumn::toColumnType(id value) const
    {
        return [value longLongValue];
    }
    id LongLongColumn::toObjCObject(long long value) const
    {
        return @(value);
    }

};