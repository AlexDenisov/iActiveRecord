//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "ShortColumn.h"

namespace AR {

    bool ColumnInternal<short>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value shortValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<short>::sqlType(void) const {
        return "integer";
    }
};