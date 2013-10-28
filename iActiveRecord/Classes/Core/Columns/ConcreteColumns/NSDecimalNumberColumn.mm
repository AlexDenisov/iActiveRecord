//
// Created by Alex Denisov on 10.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "NSDecimalNumberColumn.h"
namespace AR {

    static NSLocale *posixLocale()
    {
        static NSLocale *posixLocale;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        });
        return posixLocale;
    }

    bool NSDecimalNumberColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        NSDecimalNumber *number = value;
        NSString *stringValue = [number descriptionWithLocale:posixLocale()];
        return sqlite3_bind_text(statement, columnIndex, [stringValue UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
    }

    const char *NSDecimalNumberColumn::sqlType(void) const {
        return "text";
    }

    NSString *NSDecimalNumberColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSDecimalNumber *value = objc_getAssociatedObject(record, this->columnKey());
        return [value descriptionWithLocale:posixLocale()];
    }

    NSDecimalNumber *__strong NSDecimalNumberColumn::toColumnType(id value) const
    {
        return value;
    }

    id NSDecimalNumberColumn::toObjCObject(NSDecimalNumber *value) const
    {
        return value;
    }
};
