//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "IntColumn.h"

namespace AR {

    bool IntColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
    }

    const char *IntColumn::sqlType(void) const {
        return "integer";
    }

    NSString *IntColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    int IntColumn::toColumnType(id value) const
    {
        return [value intValue];
    }

    id IntColumn::toObjCObject(int value) const
    {
        return @(value);
    }

};