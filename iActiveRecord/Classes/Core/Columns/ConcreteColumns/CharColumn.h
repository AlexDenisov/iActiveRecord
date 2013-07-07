//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "ColumnInternal.h"

namespace AR {
    template <>
    class ColumnInternal <char> : public IColumnInternal
    {
    private:
        static char accessorImpl(ActiveRecord *receiver, SEL _cmd);
        static void mutatorImpl(ActiveRecord *receiver, SEL _cmd, char value);

    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
        const char *sqlType(void) const override;

        NSString *sqlValueFromRecord(ActiveRecord *record) const override;

        const IMP accessor(void) const
        {
            return reinterpret_cast<IMP>(&ColumnInternal::accessorImpl);
        }

        const IMP mutator(void) const
        {
            return reinterpret_cast<IMP>(&ColumnInternal::mutatorImpl);
        }
    };
};
