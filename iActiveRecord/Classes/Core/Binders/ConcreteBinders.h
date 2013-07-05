//
// Created by Alex Denisov on 05.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "Binder.h"

namespace AR {

    template <>
    class Binder <ARColumnTypePrimitiveChar>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value charValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <ARColumnTypePrimitiveUnsignedChar>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <ARColumnTypePrimitiveShort>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value shortValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <ARColumnTypePrimitiveUnsignedShort>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <ARColumnTypePrimitiveInt>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
        }
    };

};
