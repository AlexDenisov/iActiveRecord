//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedLongLongColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    unsigned long long ColumnInternal<unsigned long long>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] unsignedLongLongValue];
    }

    void ColumnInternal<unsigned long long>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, unsigned long long value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<unsigned long long>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value unsignedLongLongValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned long long>::sqlType(void) const {
        return "integer";
    }

};