//
//  ARColumn.m
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <objc/runtime.h>
#import "ARColumn.h"
#import "ARColumn_Private.h"
#import "NSString+uppercaseFirst.h"
#import "ActiveRecord_Private.h"
#import "ConcreteColumns.h"

@implementation ARColumn
{
    char *_columnKey;
}

- (instancetype)initWithProperty:(objc_property_t)property ofClass:(Class)aClass {
    self = [super init];
    if (self) {
        self.internal = NULL;

        self.recordClass = aClass;
        _dynamic = NO;
        self->_associationPolicy = OBJC_ASSOCIATION_ASSIGN;
        const char *propertyName = property_getName(property);
        size_t propertyNameLength = strlen(propertyName);
        _columnKey = (char *)calloc( propertyNameLength + 1, sizeof(char) );
        strcpy(_columnKey, propertyName);
        
        self->_columnName = [[NSString alloc] initWithUTF8String:_columnKey];
        
        //  set default setter/getter
        [self setSetterFromAttribute:NULL];
        [self setGetterFromAttribute:NULL];
        uint attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        for (int i = 0; i < attributesCount; i++) {
            switch (attributes[i].name[0]) {
                case 'T':
                    if (![self setPropertyTypeFromAttribute:attributes[i].value]) {
                        NSLog(@"Unsupported property type '%s' for column '%s'",
                              attributes[i].value,
                              propertyName);
                    }
                    break;
                case 'C':
                    self->_associationPolicy = OBJC_ASSOCIATION_COPY_NONATOMIC;
                    break;
                case '&':
                    self->_associationPolicy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
                    break;
                case 'G':     // Getter
                    [self setGetterFromAttribute:attributes[i].value];
                    break;
                case 'S':     // Setter
                    [self setSetterFromAttribute:attributes[i].value];
                    break;
                case 'D':     // is dynamic property?
                    _dynamic = YES;
                    break;
                default:
                    break;
            }
        }
        free(attributes);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"Column: %@ %@",
            NSStringFromClass(self.columnClass),
            self.columnName];
}

- (BOOL)isEqual:(id)object {
    ARColumn *right = (ARColumn *)object;
    BOOL result = YES;
    if (![self.columnName isEqualToString:right.columnName]) {
        result = NO;
    }
    if (self.columnClass != right.columnClass) {
        result = NO;
    }
    return result;
}

- (void)dealloc {
    delete _internal;
    free(_columnKey);
}

#pragma mark - Property Meta Parser

- (BOOL)setPropertyTypeFromAttribute:(const char *)anAttribute {
    BOOL result = YES;
    char *type = NULL;
    //  classes described as @"ClassName"
    if (anAttribute[0] == '@') {
        unsigned long length = strlen(anAttribute) - 3;
        type = (char *)calloc( length, sizeof(char) );
        strncpy(type, anAttribute + 2, length);
        self.columnClass = [objc_getClass(type) class];
        if (self.columnClass == [NSString class]) {
            self.internal = new AR::NSStringColumn;
            self.internal->setColumnKey(self->_columnKey);
        } else if (self.columnClass == [NSDate class]) {
            self.internal = new AR::NSDateColumn;
            self.internal->setColumnKey(self->_columnKey);
        } else if (self.columnClass == [NSDecimalNumber class]) {
            self.internal = new AR::NSDecimalNumberColumn;
            self.internal->setColumnKey(self->_columnKey);
        } else if (self.columnClass == [NSNumber class]) {
            self.internal = new AR::NSNumberColumn;
            self.internal->setColumnKey(self->_columnKey);
        } else {
            self->_columnType = ARColumnTypeComposite;
        }
        free(type);
    } else {
        self->_associationPolicy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        
        switch (anAttribute[0]) {
            case _C_CHR:     // BOOL, char
                self->_columnType = ARColumnTypePrimitiveChar;
                self.internal = new AR::CharColumn;
                break;
            case _C_UCHR:     // unsigned char
                self->_columnType = ARColumnTypePrimitiveUnsignedChar;
                self.internal = new AR::UnsignedCharColumn;
                break;
            case _C_SHT:     // short
                self->_columnType = ARColumnTypePrimitiveShort;
                self.internal = new AR::ShortColumn;
                break;
            case _C_USHT:     // unsigned short
                self->_columnType = ARColumnTypePrimitiveUnsignedShort;
                self.internal = new AR::UnsignedShortColumn;
                break;
            case _C_INT:     // int, NSInteger
                self->_columnType = ARColumnTypePrimitiveInt;
                self.internal = new AR::IntColumn;
                break;
            case _C_UINT:     // uint, NSUinteger
                self->_columnType = ARColumnTypePrimitiveUnsignedInt;
                self.internal = new AR::UnsignedIntColumn;
                break;
            case _C_LNG:     // long
                self->_columnType = ARColumnTypePrimitiveLong;
                self.internal = new AR::LongColumn;
                break;
            case _C_ULNG:     // unsigned long
                self->_columnType = ARColumnTypePrimitiveUnsignedLong;
                self.internal = new AR::UnsignedLongColumn;
                break;
            case _C_LNG_LNG:     // long long
                self->_columnType = ARColumnTypePrimitiveLongLong;
                self.internal = new AR::LongLongColumn;
                break;
            case _C_ULNG_LNG:     // unsigned long long
                self->_columnType = ARColumnTypePrimitiveUnsignedLongLong;
                self.internal = new AR::UnsignedLongLongColumn;
                break;
            case _C_FLT:     // float, CGFloat
                self->_columnType = ARColumnTypePrimitiveFloat;
                self.internal = new AR::FloatColumn;
                break;
            case _C_DBL:     // double
                self->_columnType = ARColumnTypePrimitiveDouble;
                self.internal = new AR::DoubleColumn;
                break;
            default:
                result = NO;
                break;
        }
        if (self.internal != NULL) {
            self.internal->setColumnKey(self->_columnKey);
        }
    }
    return result;
}

- (void)setSetterFromAttribute:(const char *)anAttribute {
    if (anAttribute) {
        self.setter = [NSString stringWithUTF8String:anAttribute];
    }else {
        self.setter = [NSString stringWithFormat:@"set%@:", [self.columnName uppercaseFirst]];
    }
}

- (void)setGetterFromAttribute:(const char *)anAttribute {
    if (anAttribute) {
        self.getter = [NSString stringWithUTF8String:anAttribute];
    } else {
        self.getter = [NSString stringWithFormat:@"%@", self.columnName];
    }
}

- (NSString *)sqlValueForRecord:(ActiveRecord *)record {
    if (self->_columnType == ARColumnTypeComposite) {
        id value =  objc_getAssociatedObject(record, self->_columnKey);
        return [value performSelector:@selector(toSql)];
    } else {
        return self.internal->sqlValueFromRecord(record);
    }
}

- (const char *)sqlType {
    if (self.columnType == ARColumnTypeComposite) {
        return [[self.columnClass performSelector:@selector(sqlType)] UTF8String];
    } else {
        return self.internal->sqlType();
    }
}

- (const char *)columnKey
{
    if (self.internal != NULL) {
        return self.internal->columnKey();
    } else {
        return _columnKey;
    }
}


@end
