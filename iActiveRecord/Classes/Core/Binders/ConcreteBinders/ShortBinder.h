//
// Created by Alex Denisov on 06.07.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//

#pragma once

#include "Binder.h"

namespace AR {
    template <>
    class Binder <short> : public IBinder
    {
    public:
        bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
    };
};
