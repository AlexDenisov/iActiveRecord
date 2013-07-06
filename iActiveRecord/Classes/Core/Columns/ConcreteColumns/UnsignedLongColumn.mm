//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedLongColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    unsigned long ColumnInternal<unsigned long>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] unsignedLongValue];
    }

    void ColumnInternal<unsigned long>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, unsigned long value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<unsigned long>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned long>::sqlType(void) const {
        return "integer";
    }
};

