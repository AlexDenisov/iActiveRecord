//
//  ARDynamicAccessor.m
//  iActiveRecord
//
//  Created by Alex Denisov on 01.12.12.
//
//

#import "ARDynamicAccessor.h"
#import "ARColumn_Private.h"
#import "ActiveRecord_Private.h"

static void compositeDynamicSetter(ActiveRecord *record, SEL setter, id value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    [record setValue:value forColumn:column];
}

static id compositeDynamicGetter(ActiveRecord *record, SEL getter) {
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [record valueForColumn:column];
}

@implementation ARDynamicAccessor

+ (void)addAccessorForColumn:(ARColumn *)column {

    IMP dynamicSetterIMP = NULL;
    IMP dynamicGetterIMP = NULL;

    if (column.columnType == ARColumnTypeComposite) {
        dynamicGetterIMP = (IMP)compositeDynamicGetter;
        dynamicSetterIMP = (IMP)compositeDynamicSetter;
    } else {
        dynamicGetterIMP = column.internal->accessor();
        dynamicSetterIMP = column.internal->mutator();
    }

    if (dynamicGetterIMP != NULL) {
        class_addMethod(column.recordClass,
                        NSSelectorFromString(column.getter),
                        dynamicGetterIMP,
                        NULL);

    }
    if (dynamicSetterIMP != NULL) {
        class_addMethod(column.recordClass,
                        NSSelectorFromString(column.setter),
                        dynamicSetterIMP,
                        NULL);
    }
}

@end
