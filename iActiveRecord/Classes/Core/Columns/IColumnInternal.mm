//
//  IColumnInternal.c
//  iActiveRecord
//
//  Created by Alex Denisov on 10.11.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "IColumnInternal.h"

namespace AR {
    IColumnInternal::columnKey() const
    {
        return m_columnKey;
    }
    
    IColumnInternal::setColumnKey(const char *key)
    {
        size_t propertyNameLength = strlen(key);
        m_columnKey = (char *)calloc(propertyNameLength + 1, sizeof(char));
        strcpy(m_columnKey, key);
    }
    
    IColumnInternal::~IColumnInternal()
    {
        free(m_columnKey);
    }
}
