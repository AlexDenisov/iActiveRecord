//
//  ARColumnType.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.11.12.
//
//

typedef enum ARColumnType {
    ARColumnTypeUnknown,    // uknown DataType, not supported (yet?)
    ARColumnTypeComposite,  // NSObject's subclass
    ARColumnTypePrimitiveInteger
} ARColumnType;