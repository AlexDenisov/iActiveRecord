//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "LongColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    long ColumnInternal<long>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] longValue];
    }

    void ColumnInternal<long>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, long value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<long>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int64(statement, columnIndex, [value longValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<long>::sqlType(void) const {
        return "integer";
    }

    NSString *ColumnInternal<long>::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

};
