//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "FloatColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    float ColumnInternal<float>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] floatValue];
    }

    void ColumnInternal<float>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, float value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<float>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_double(statement, columnIndex, [value floatValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<float>::sqlType(void) const {
        return "real";
    }

};
