//
// Created by Alex Denisov on 07.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//


#include "NSStringColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    NSString *ColumnInternal<NSString>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [receiver valueForColumn:column];
    }

    void ColumnInternal<NSString>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, NSString *value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:value forColumn:column];
    }

    bool ColumnInternal<NSString>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_text(statement, columnIndex, [value UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
    }

    const char *ColumnInternal<NSString>::sqlType(void) const {
        return "text";
    }

    NSString *ColumnInternal<NSString>::sqlValueFromRecord(ActiveRecord *record) const
    {
        return objc_getAssociatedObject(record, this->columnKey());
    }

};