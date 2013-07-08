//
// Created by Alex Denisov on 08.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "ColumnInternal.h"

namespace AR {
    class NSDateColumn : public ColumnInternal<NSDate *>
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
        const char *sqlType(void) const override;

        NSString *sqlValueFromRecord(ActiveRecord *record) const override;

        NSDate *__strong toColumnType(id value) const override;
        id toObjCObject(NSDate *value) const override;
    };
};
