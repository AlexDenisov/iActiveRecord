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
    class Binder <int>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <unsigned int>
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
            return sqlite3_bind_int64(statement, columnIndex, [value longValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <unsigned long>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <long long>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int64(statement, columnIndex, [value longLongValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <unsigned long long>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongLongValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <float>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_double(statement, columnIndex, [value floatValue]) == SQLITE_OK;
        }
    };

    template <>
    class Binder <double>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_double(statement, columnIndex, [value doubleValue]) == SQLITE_OK;
        }
    };

};
