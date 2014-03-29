//
//  IndicesMacroHelper.h
//  iActiveRecord
//
//  Created by Alex Denisov on 02.07.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#define indices_do(indices) \
    + (void)initializeIndices { \
        indices \
    }

#define add_index_on(aField) \
    [self performSelector: @selector(addIndexOn:) withObject: @ ""#aField ""];
