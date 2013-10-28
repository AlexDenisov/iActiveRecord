//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "ColumnInternal.h"

namespace AR {
    class UnsignedLongColumn : public ColumnInternal<unsigned long>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
        const char *sqlType(void) const override;

        NSString *sqlValueFromRecord(ActiveRecord *record) const override;

        unsigned long toColumnType(id value) const override;
        id toObjCObject(unsigned long value) const override;
    };
};