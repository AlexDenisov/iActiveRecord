//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include <sqlite3.h>
#include "IColumnInternal.h"

namespace AR {

    template <typename columnType>
    class ColumnInternal : public IColumnInternal {
    private:
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            throw std::exception();
        }
        const char *sqlType(void) const
        {
            throw std::exception();
        }
    };

};

