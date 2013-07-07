//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedIntColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    unsigned int ColumnInternal<unsigned int>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] unsignedIntValue];
    }

    void ColumnInternal<unsigned int>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, unsigned int value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<unsigned int>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedIntValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned int>::sqlType(void) const {
        return "integer";
    }

    NSString *ColumnInternal<unsigned int>::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

};