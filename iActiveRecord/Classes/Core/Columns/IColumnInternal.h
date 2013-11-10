//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#include "sqlite3.h"

@class ActiveRecord;

namespace AR {

    class IColumnInternal {
    private:
        char *m_columnKey;
    public:
        virtual ~IColumnInternal();
        
        virtual bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const = 0;
        virtual const char *sqlType(void) const = 0;
        
        virtual const IMP accessor(void) const = 0;
        virtual const IMP mutator(void) const = 0;
        
        virtual NSString *sqlValueFromRecord(ActiveRecord *record) const = 0;

        void setColumnKey(const char *key);
        const char* columnKey() const;
    };

};
