//
//  ARColumnManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 01.05.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARSchemaManager.h"
#import "ARColumn.h"
#import "NSMutableDictionary+valueToArray.h"

@implementation ARSchemaManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.schemes = [NSMutableDictionary new];
    self.indices = [NSMutableDictionary new];
    return self;
}

- (void)registerSchemeForRecord:(Class)aRecordClass {
    Class ActiveRecordClass = NSClassFromString(@"NSObject");
    id CurrentClass = aRecordClass;
    while (nil != CurrentClass && CurrentClass != ActiveRecordClass) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(CurrentClass, &outCount);
        NSString *recordName = [aRecordClass performSelector:@selector(recordName)];
        for (i = 0; i < outCount; i++) {
            ARColumn *column = [[ARColumn alloc] initWithProperty:properties[i] ofClass:aRecordClass];
            if (!column.isDynamic) {
                continue;
            }
            [self.schemes addValue:column
                      toArrayNamed:recordName];
        }
        free(properties);
        CurrentClass = class_getSuperclass(CurrentClass);
    }
}

- (NSArray *)columnsForRecord:(Class)aRecordClass {
    return [[self.schemes valueForKey:[aRecordClass performSelector:@selector(recordName)]] allObjects];
}

- (void)addIndexOnColumn:(NSString *)aColumn ofRecord:(Class)aRecordClass {
    [self.indices addValue:aColumn
              toArrayNamed:[aRecordClass performSelector:@selector(recordName)]];
}

- (NSArray *)indicesForRecord:(Class)aRecordClass {
    return [self.indices valueForKey:[aRecordClass performSelector:@selector(recordName)]];
}

@end
