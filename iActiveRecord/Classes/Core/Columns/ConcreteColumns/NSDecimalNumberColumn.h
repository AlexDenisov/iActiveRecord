//
// Created by Alex Denisov on 10.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "ColumnInternal.h"

namespace AR {
    class NSDecimalNumberColumn : public ColumnInternal<NSDecimalNumber *>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
        const char *sqlType(void) const override;

        NSString *sqlValueFromRecord(ActiveRecord *record) const override;

        NSDecimalNumber *__strong toColumnType(id value) const override;
        id toObjCObject(NSDecimalNumber *value) const override;
    };
};
