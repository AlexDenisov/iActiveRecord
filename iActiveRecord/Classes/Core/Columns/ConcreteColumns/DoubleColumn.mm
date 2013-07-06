//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "DoubleColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    double ColumnInternal<double>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] doubleValue];
    }

    void ColumnInternal<double>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, double value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<double>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_double(statement, columnIndex, [value doubleValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<double>::sqlType(void) const {
        return "real";
    }

};