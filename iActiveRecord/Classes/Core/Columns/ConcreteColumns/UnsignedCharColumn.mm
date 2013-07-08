//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedCharColumn.h"

namespace AR {

    bool UnsignedCharColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
    }

    const char *UnsignedCharColumn::sqlType(void) const {
        return "integer";
    }

    NSString *UnsignedCharColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

    unsigned char AR::UnsignedCharColumn::toColumnType(id value) const
    {
        return [value unsignedCharValue];
    }

    id AR::UnsignedCharColumn::toObjCObject(unsigned char value) const
    {
        return @(value);
    }

};