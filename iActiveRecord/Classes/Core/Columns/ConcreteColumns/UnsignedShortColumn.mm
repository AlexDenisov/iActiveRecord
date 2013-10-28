//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedShortColumn.h"

namespace AR {

    bool UnsignedShortColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedShortValue]) == SQLITE_OK;
    }

    const char *UnsignedShortColumn::sqlType(void) const {
        return "integer";
    }

    NSString *UnsignedShortColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    unsigned short UnsignedShortColumn::toColumnType(id value) const
    {
        return [value unsignedShortValue];
    }

    id UnsignedShortColumn::toObjCObject(unsigned short value) const
    {
        return @(value);
    }

};