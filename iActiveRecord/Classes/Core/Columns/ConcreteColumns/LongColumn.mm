//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "LongColumn.h"

namespace AR {

    bool LongColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value longValue]) == SQLITE_OK;
    }

    const char *LongColumn::sqlType(void) const {
        return "integer";
    }

    NSString *LongColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    long LongColumn::toColumnType(id value) const
    {
        return [value longValue];
    }

    id LongColumn::toObjCObject(long value) const
    {
        return @(value);
    }

};
