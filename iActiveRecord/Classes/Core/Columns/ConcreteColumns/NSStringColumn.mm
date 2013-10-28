//
// Created by Alex Denisov on 07.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//


#include "NSStringColumn.h"

namespace AR {

    bool NSStringColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_text(statement, columnIndex, [value UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
    }

    const char *NSStringColumn::sqlType(void) const {
        return "text";
    }

    NSString *NSStringColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        return objc_getAssociatedObject(record, this->columnKey());
    }

    NSString *__strong NSStringColumn::toColumnType(id value) const
    {
        return value;
    }
    id NSStringColumn::toObjCObject(NSString *value) const
    {
        return value;
    }
};