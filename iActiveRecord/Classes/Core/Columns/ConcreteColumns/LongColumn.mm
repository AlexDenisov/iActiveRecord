//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "LongColumn.h"

namespace AR {

    bool ColumnInternal<long>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value longValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<long>::sqlType(void) const {
        return "integer";
    }

};
