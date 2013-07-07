//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "IntColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    int ColumnInternal<int>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] intValue];
    }

    void ColumnInternal<int>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, int value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<int>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value intValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<int>::sqlType(void) const {
        return "integer";
    }

    NSString *ColumnInternal<int>::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

};