//
// Created by Alex Denisov on 05.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "Binder.h"

@class PrimitiveModel;

namespace AR {

    template <>
    class Binder <char>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value charValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <unsigned char>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <short>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value shortValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <unsigned short>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value unsignedShortValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <NSInteger>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <NSUInteger>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value unsignedIntegerValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <long>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value longValue]) == SQLITE_OK;
        }
    };

};
