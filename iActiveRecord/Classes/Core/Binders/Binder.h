//
// Created by Alex Denisov on 04.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include <sqlite3.h>
#include "ARColumnType.h"
#include "IBinder.h"

namespace AR {

    template <ARColumnType type>
    class Binder : public IBinder {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
        {
            #warning throw exception
            return false;
        }
    };

};

