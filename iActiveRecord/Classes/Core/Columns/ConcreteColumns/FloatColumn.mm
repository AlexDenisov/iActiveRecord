//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "FloatColumn.h"

namespace AR {

    bool FloatColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_double(statement, columnIndex, [value floatValue]) == SQLITE_OK;
    }

    const char *FloatColumn::sqlType(void) const {
        return "real";
    }

    NSString *FloatColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    float FloatColumn::toColumnType(id value) const
    {
        return [value floatValue];
    }

    id FloatColumn::toObjCObject(float value) const
    {
        return @(value);
    }

};
