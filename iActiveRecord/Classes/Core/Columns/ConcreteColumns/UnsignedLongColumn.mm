//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedLongColumn.h"

namespace AR {

    bool UnsignedLongColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongValue]) == SQLITE_OK;
    }

    const char *UnsignedLongColumn::sqlType(void) const {
        return "integer";
    }

    NSString *UnsignedLongColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    unsigned long UnsignedLongColumn::toColumnType(id value) const
    {
        return [value unsignedLongValue];
    }

    id UnsignedLongColumn::toObjCObject(unsigned long value) const
    {
        return @(value);
    }
};

