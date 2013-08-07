//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "DoubleColumn.h"

namespace AR {

    bool DoubleColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_double(statement, columnIndex, [value doubleValue]) == SQLITE_OK;
    }

    const char *DoubleColumn::sqlType(void) const {
        return "real";
    }

    NSString *DoubleColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    double DoubleColumn::toColumnType(id value) const
    {
        return [value doubleValue];
    }

    id DoubleColumn::toObjCObject(double value) const
    {
        return @(value);
    }

};