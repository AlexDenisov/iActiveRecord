//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "Binder.h"
#include "ARColumnType.h"

namespace AR {

    template <>
    class Binder <ARColumnTypePrimitiveChar>
    {
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            return sqlite3_bind_int(statement, columnIndex, [value charValue]) == SQLITE_OK;
        }
    };

};
