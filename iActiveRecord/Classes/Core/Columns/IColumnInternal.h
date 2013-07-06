//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "sqlite3.h"

namespace AR {
    class IColumnInternal {
    public:
        virtual bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const = 0;
        virtual const char *sqlType(void) const = 0;
        virtual const IMP accessor(void) const = 0;
        virtual const IMP mutator(void) const = 0;

        virtual ~IColumnInternal(){};

    };

};
