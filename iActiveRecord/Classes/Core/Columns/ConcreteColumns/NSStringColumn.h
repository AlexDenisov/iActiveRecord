//
// Created by Alex Denisov on 07.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "ColumnInternal.h"

namespace AR {
    class NSStringColumn : public ColumnInternal<NSString *>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
        const char *sqlType(void) const override;

        NSString *sqlValueFromRecord(ActiveRecord *record) const override;

        NSString *__strong toColumnType(id value) const override;
        id toObjCObject(NSString *value) const override;
    };
};
