//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include <sqlite3.h>
#include <exception>
#include "IColumnInternal.h"
#include "ARColumn_Private.h"
#include "ActiveRecord_Private.h"

namespace AR {

    template <typename columnType>
    class ColumnInternal : public IColumnInternal {
    private:
        static columnType accessorImpl(ActiveRecord *receiver, SEL _cmd)
        {
            ARColumn *column = [receiver columnWithGetterNamed:NSStringFromSelector(_cmd)];
            id value = [receiver valueForColumn:column];
            ColumnInternal<columnType> *columnInternal = dynamic_cast<ColumnInternal<columnType> *>(column.internal);
            return columnInternal->toColumnType(value);
        }
        static void mutatorImpl(ActiveRecord *receiver, SEL _cmd, columnType value)
        {
            ARColumn *column = [receiver columnWithSetterNamed:NSStringFromSelector(_cmd)];
            ColumnInternal<columnType> *columnInternal = dynamic_cast<ColumnInternal<columnType> *>(column.internal);
            id objcValue = columnInternal->toObjCObject(value);
            [receiver setValue:objcValue forColumn:column];
        }

    public:

        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            throw std::exception();
        }

        const char *sqlType(void) const
        {
            throw std::exception();
        }

        NSString *sqlValueFromRecord(ActiveRecord *record) const
        {
            throw std::exception();
        }

        const IMP accessor(void) const
        {
            return reinterpret_cast<IMP>(&accessorImpl);
        }

        const IMP mutator(void) const
        {
            return reinterpret_cast<IMP>(&mutatorImpl);
        }

        virtual columnType toColumnType(id value) const = 0;
        virtual id toObjCObject(columnType value) const = 0;

    };

};
