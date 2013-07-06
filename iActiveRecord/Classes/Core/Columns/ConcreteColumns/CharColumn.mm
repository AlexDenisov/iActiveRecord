//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "CharColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    char ColumnInternal<char>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] charValue];
    }

    void ColumnInternal<char>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, char value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<char>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value charValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<char>::sqlType() const {
        return "integer";
    }

};
