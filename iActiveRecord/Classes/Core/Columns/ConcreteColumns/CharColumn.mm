//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "CharColumn.h"

namespace AR {

    bool CharColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value charValue]) == SQLITE_OK;
    }

    const char *CharColumn::sqlType() const {
        return "integer";
    }

    NSString *CharColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    char CharColumn::toColumnType(id value) const
    {
        return [value charValue];
    }

    id CharColumn::toObjCObject(char value) const
    {
        return @(value);
    }

};
