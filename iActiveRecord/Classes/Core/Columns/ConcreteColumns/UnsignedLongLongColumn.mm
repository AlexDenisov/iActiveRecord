//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedLongLongColumn.h"

namespace AR {

    bool UnsignedLongLongColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongLongValue]) == SQLITE_OK;
    }

    const char *UnsignedLongLongColumn::sqlType(void) const {
        return "integer";
    }

    NSString *UnsignedLongLongColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    unsigned long long UnsignedLongLongColumn::toColumnType(id value) const
    {
        return [value unsignedLongLongValue];
    }

    id UnsignedLongLongColumn::toObjCObject(unsigned long long value) const
    {
        return @(value);
    }

};