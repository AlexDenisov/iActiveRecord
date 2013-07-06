//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedCharColumn.h"

namespace AR {

    bool ColumnInternal<unsigned char>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned char>::sqlType(void) const {
        return "integer";
    }
};