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

@implementation ARDynamicAccessor

+ (void)addAccessorForColumn:(ARColumn *)column {
    switch (column->_columnType) {
        case ARColumnTypeComposite:
        {
            class_addMethod(column->_recordClass,
                            NSSelectorFromString(column.setter),
                            (IMP)compositeDynamicSetter,
                            NULL);
            
            class_addMethod(column->_recordClass,
                            NSSelectorFromString(column.getter),
                            (IMP)compositeDynamicGetter,
                            NULL);
        }break;
            
        default:
            NSLog(@"Unknown Column type %d", column->_columnType);
            break;
    }
}

#pragma mark - Private accessors implementation

static void compositeDynamicSetter(ActiveRecord *record, SEL setter, id value) {
    ARColumn *column = [record columnWithSetterNamed:NSStringFromSelector(setter)];
    [record setValue:value forColumn:column];
}

static id compositeDynamicGetter(ActiveRecord *record, SEL getter){
    ARColumn *column = [record columnWithGetterNamed:NSStringFromSelector(getter)];
    return [record valueForColumn:column];
}

@end
