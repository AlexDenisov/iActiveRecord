//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "ShortColumn.h"

namespace AR {

    bool ShortColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value shortValue]) == SQLITE_OK;
    }

    const char *ShortColumn::sqlType(void) const {
        return "integer";
    }

    NSString *ShortColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    short ShortColumn::toColumnType(id value) const
    {
        return [value shortValue];
    }

    id ShortColumn::toObjCObject(short value) const
    {
        return @(value);
    }

};