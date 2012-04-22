//
//  AREnum.h
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

typedef enum {
    ARStorageCache,
    ARStorageDocuments
} ARStorageDirectory;

typedef enum {
    ARDependencyNullify,
    ARDependencyDestroy
} ARDependency;

typedef enum {
    ARRelationTypeNone,
    ARRelationTypeBelongsTo,
    ARRelationTypeHasMany,
    ARRelationTypeHasManyThrough
} ARRelationType;