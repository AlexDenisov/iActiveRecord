//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedCharColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    unsigned char ColumnInternal<unsigned char>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] unsignedCharValue];
    }

    void ColumnInternal<unsigned char>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, unsigned char value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<unsigned char>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedCharValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned char>::sqlType(void) const {
        return "integer";
    }

};