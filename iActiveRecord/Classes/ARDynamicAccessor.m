//
//  ARDynamicAccessor.m
//  iActiveRecord
//
//  Created by Alex Denisov on 01.12.12.
//
//

#import "ARDynamicAccessor.h"
#import "ARColumn.h"
#import "ARColumn_Private.h"
#import "ActiveRecord_Private.h"

#warning find the way to do it more cleanest

@implementation ARDynamicAccessor

+ (void)addAccessorForColumn:(ARColumn *)column {
    IMP dynamicSetterIMP = NULL;
    IMP dynamicGetterIMP = NULL;
    
    switch (column->_columnType) {
        case ARColumnTypeComposite:{
            dynamicGetterIMP = (IMP)compositeDynamicGetter;
            dynamicSetterIMP = (IMP)compositeDynamicSetter;
        }break;
        case ARColumnTypePrimitiveInt:{
            dynamicGetterIMP = (IMP)integerDynamicGetter;
            dynamicSetterIMP = (IMP)integerDynamicSetter;
        }break;
        case ARColumnTypePrimitiveUnsignedInt:{
            dynamicGetterIMP = (IMP)unsignedIntegerDynamicGetter;
            dynamicSetterIMP = (IMP)unsignedIntegerDynamicSetter;
        }break;
        case ARColumnTypePrimitiveChar:{
            dynamicGetterIMP = (IMP)charDynamicGetter;
            dynamicSetterIMP = (IMP)charDynamicSetter;
        }break;
        case ARColumnTypePrimitiveUnsignedChar:{
            dynamicGetterIMP = (IMP)unsignedCharDynamicGetter;
            dynamicSetterIMP = (IMP)unsignedCharDynamicSetter;
        }break;
        case ARColumnTypePrimitiveShort:{
            dynamicGetterIMP = (IMP)shortDynamicGetter;
            dynamicSetterIMP = (IMP)shortDynamicSetter;
        }break;
        case ARColumnTypePrimitiveUnsignedShort:{
            dynamicGetterIMP = (IMP)unsignedShortDynamicGetter;
            dynamicSetterIMP = (IMP)unsignedShortDynamicSetter;
        }break;
        case ARColumnTypePrimitiveLong:{
            dynamicGetterIMP = (IMP)longDynamicGetter;
            dynamicSetterIMP = (IMP)longDynamicSetter;
        }break;
        case ARColumnTypePrimitiveUnsignedLong:{
            dynamicGetterIMP = (IMP)unsignedLongDynamicGetter;
            dynamicSetterIMP = (IMP)unsignedLongDynamicSetter;
        }break;
        case ARColumnTypePrimitiveLongLong:{
            dynamicGetterIMP = (IMP)longLongDynamicGetter;
            dynamicSetterIMP = (IMP)longLongDynamicSetter;
        }break;
        case ARColumnTypePrimitiveUnsignedLongLong:{
            dynamicGetterIMP = (IMP)unsignedLongLongDynamicGetter;
            dynamicSetterIMP = (IMP)unsignedLongLongDynamicSetter;
        }break;
        case ARColumnTypePrimitiveFloat:{
            dynamicGetterIMP = (IMP)floatDynamicGetter;
            dynamicSetterIMP = (IMP)floatDynamicSetter;
        }break;
        case ARColumnTypePrimitiveDouble:{
            dynamicGetterIMP = (IMP)doubleDynamicGetter;
            dynamicSetterIMP = (IMP)doubleDynamicSetter;
        }break;
        default:
            NSLog(@"Unknown Column type %d", column->_columnType);
            break;
    }
    
    if (dynamicGetterIMP != NULL) {
        class_addMethod(column->_recordClass,
                        NSSelectorFromString(column.getter),
                        dynamicGetterIMP,
                        NULL);
        
    }
    if (dynamicSetterIMP != NULL) {
        class_addMethod(column->_recordClass,
                        NSSelectorFromString(column.setter),
                        dynamicSetterIMP,
                        NULL);
    }
}

#pragma mark - Private accessors implementation

#pragma mark Composite accessors

static void compositeDynamicSetter(ActiveRecord *record, SEL setter, id value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    [record setValue:value forColumn:column];
}

static id compositeDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [record valueForColumn:column];
}

#pragma mark Integer accessors

static void integerDynamicSetter(ActiveRecord *record, SEL setter, int intValue) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id value = [NSNumber numberWithInt:intValue];
    [record setValue:value forColumn:column];
}

static int integerDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] integerValue];
}

#pragma mark Unsigned integer accessors

static void unsignedIntegerDynamicSetter(ActiveRecord *record, SEL setter, unsigned int intValue) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id value = [NSNumber numberWithUnsignedInt:intValue];
    [record setValue:value forColumn:column];
}

static unsigned int unsignedIntegerDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] unsignedIntegerValue];
}

#pragma mark char accessors

static void charDynamicSetter(ActiveRecord *record, SEL setter, char value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithChar:value];
    [record setValue:numValue forColumn:column];
}

static char charDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] charValue];
}

#pragma mark unsigned char accessors

static void unsignedCharDynamicSetter(ActiveRecord *record, SEL setter, unsigned char value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithUnsignedChar:value];
    [record setValue:numValue forColumn:column];
}

static unsigned char unsignedCharDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] unsignedCharValue];
}

#pragma mark short accessors

static void shortDynamicSetter(ActiveRecord *record, SEL setter, short value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithShort:value];
    [record setValue:numValue forColumn:column];
}

static char shortDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] shortValue];
}

#pragma mark unsigned short accessors

static void unsignedShortDynamicSetter(ActiveRecord *record, SEL setter, unsigned short value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithUnsignedShort:value];
    [record setValue:numValue forColumn:column];
}

static unsigned short unsignedShortDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] unsignedShortValue];
}

#pragma mark long accessors

static void longDynamicSetter(ActiveRecord *record, SEL setter, long value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithLong:value];
    [record setValue:numValue forColumn:column];
}

static long longDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] longValue];
}

#pragma mark unsigned long accessors

static void unsignedLongDynamicSetter(ActiveRecord *record, SEL setter, unsigned long value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithUnsignedLong:value];
    [record setValue:numValue forColumn:column];
}

static unsigned long unsignedLongDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] unsignedLongValue];
}

#pragma mark long long accessors

static void longLongDynamicSetter(ActiveRecord *record, SEL setter, long long value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithLongLong:value];
    [record setValue:numValue forColumn:column];
}

static long long longLongDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] longLongValue];
}

#pragma mark unsigned long long accessors

static void unsignedLongLongDynamicSetter(ActiveRecord *record, SEL setter, unsigned long long value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithUnsignedLongLong:value];
    [record setValue:numValue forColumn:column];
}

static unsigned long long unsignedLongLongDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] unsignedLongLongValue];
}

#pragma mark float accessors

static void floatDynamicSetter(ActiveRecord *record, SEL setter, float value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithFloat:value];
    [record setValue:numValue forColumn:column];
}

static float floatDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] floatValue];
}

#pragma mark double accessors

static void doubleDynamicSetter(ActiveRecord *record, SEL setter, double value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    id numValue = [NSNumber numberWithDouble:value];
    [record setValue:numValue forColumn:column];
}

static double doubleDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [[record valueForColumn:column] doubleValue];
}

@end
