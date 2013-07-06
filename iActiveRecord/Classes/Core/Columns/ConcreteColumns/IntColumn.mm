//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "IntColumn.h"

namespace AR {

    bool ColumnInternal<int>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<int>::sqlType(void) const {
        return "integer";
    }
};