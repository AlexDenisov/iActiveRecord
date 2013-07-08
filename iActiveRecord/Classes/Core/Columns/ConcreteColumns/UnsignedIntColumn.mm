//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedIntColumn.h"

namespace AR {

    bool UnsignedIntColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedIntValue]) == SQLITE_OK;
    }

    const char *UnsignedIntColumn::sqlType(void) const {
        return "integer";
    }

    NSString *UnsignedIntColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    unsigned int UnsignedIntColumn::toColumnType(id value) const
    {
        return [value unsignedIntValue];
    }

    id UnsignedIntColumn::toObjCObject(unsigned int value) const
    {
        return @(value);
    }

};