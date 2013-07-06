//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include <sqlite3.h>
#include "IColumnInternal.h"

@class ActiveRecord;

namespace AR {

    template <typename columnType>
    class ColumnInternal : public IColumnInternal {
    private:
        static columnType accessorImpl(ActiveRecord *self, SEL _cmd)
        {
            throw std::exception();
        }
        static void mutatorImpl(ActiveRecord *self, SEL _cmd, columnType value)
        {
            throw std::exception();
        }
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            throw std::exception();
        }

        const char *sqlType(void) const
        {
            throw std::exception();
        }

        const IMP accessor(void) const
        {
            return reinterpret_cast<IMP>(&ColumnInternal<columnType>::accessorImpl);
        }

        const IMP mutator(void) const
        {
            return reinterpret_cast<IMP>(&ColumnInternal<columnType>::mutatorImpl);
        }

    };

};

