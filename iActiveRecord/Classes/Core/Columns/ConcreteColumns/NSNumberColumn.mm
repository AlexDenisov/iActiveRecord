//
//  NSNumberColumn.cpp
//  iActiveRecord
//
//  Created by Alex Denisov on 12.07.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#include "NSNumberColumn.h"
namespace AR {
    
    bool NSNumberColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value integerValue]) == SQLITE_OK;
    }
    
    const char *NSNumberColumn::sqlType(void) const {
        return "integer";
    }
    
    NSString *NSNumberColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());
        
        return [NSString stringWithFormat:@"%d", [value intValue]];
    }
    
    NSNumber *__strong NSNumberColumn::toColumnType(id value) const
    {
        return value;
    }
    
    id NSNumberColumn::toObjCObject(NSNumber *value) const
    {
        return value;
    }
};