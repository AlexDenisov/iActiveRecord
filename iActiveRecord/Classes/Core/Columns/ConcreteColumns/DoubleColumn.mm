//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "DoubleColumn.h"

namespace AR {

    bool ColumnInternal<double>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_double(statement, columnIndex, [value doubleValue]) == SQLITE_OK;
    }

};