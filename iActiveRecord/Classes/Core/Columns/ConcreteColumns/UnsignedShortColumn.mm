//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "UnsignedShortColumn.h"
#include "ActiveRecord_Private.h"

namespace AR {

    unsigned short ColumnInternal<unsigned short>::accessorImpl(ActiveRecord *receiver, SEL _cmd)
    {
        ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
        return [[receiver valueForColumn:column] unsignedShortValue];
    }

    void ColumnInternal<unsigned short>::mutatorImpl(ActiveRecord *receiver, SEL _cmd, unsigned short value)
    {
        ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
        [receiver setValue:@(value) forColumn:column];
    }

    bool ColumnInternal<unsigned short>::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value unsignedShortValue]) == SQLITE_OK;
    }

    const char *ColumnInternal<unsigned short>::sqlType(void) const {
        return "integer";
    }

    NSString *ColumnInternal<unsigned short>::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value stringValue];
    }

};