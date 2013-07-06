//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "ShortColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    short ColumnInternal<short>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] shortValue];
    }

    void ColumnInternal<short>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, short value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<short>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value shortValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<short>::sqlType(void) const {
        return "integer";
    }

};