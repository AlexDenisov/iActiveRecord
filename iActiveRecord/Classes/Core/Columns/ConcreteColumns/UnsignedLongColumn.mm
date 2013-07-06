//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedLongColumn.h"

namespace AR {

    bool ColumnInternal<unsigned long>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned long>::sqlType(void) const {
        return "integer";
    }
};
