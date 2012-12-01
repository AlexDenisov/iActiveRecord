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
    ARColumnTypePrimitiveChar,
    ARColumnTypePrimitiveUnsignedChar,
    ARColumnTypePrimitiveShort,
    ARColumnTypePrimitiveUnsignedShort,
    ARColumnTypePrimitiveInt,
    ARColumnTypePrimitiveUnsignedInt,
    ARColumnTypePrimitiveInteger = ARColumnTypePrimitiveInt,
    ARColumnTypePrimitiveUnsignedInteger = ARColumnTypePrimitiveUnsignedInt,
    ARColumnTypePrimitiveLong,
    ARColumnTypePrimitiveUnsignedLong,
    ARColumnTypePrimitiveLongLong,
    ARColumnTypePrimitiveUnsignedLongLong,
    ARColumnTypePrimitiveFloat,
    ARColumnTypePrimitiveDouble,
    ARColumnTypePrimitiveBool = ARColumnTypePrimitiveChar // boolean and char have the same type
} ARColumnType;
