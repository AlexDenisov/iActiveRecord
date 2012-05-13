//
//  ARColumnManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 01.05.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARSchemaManager.h"
#import "ARColumn_Private.h"
#import "NSMutableDictionary+valueToArray.h"

@implementation ARSchemaManager

@synthesize schemes;

static ARSchemaManager *_instance = nil;

+ (id)sharedInstance {
    @synchronized(self){
        if(_instance == nil){
            _instance = [ARSchemaManager new];
        }
        return _instance;
    }
}

- (id)init {
    self = [super init];
    self.schemes = [NSMutableDictionary new];
    return self;
}

- (void)dealloc {
    self.schemes = nil;
    [super dealloc];
}

- (void)registerSchemeForRecord:(Class)aRecordClass {
    Class ActiveRecordClass = NSClassFromString(@"NSObject");
    NSArray *ignoredFields = [aRecordClass performSelector:@selector(ignoredFields)];
    id CurrentClass = aRecordClass;
    while(nil != CurrentClass && CurrentClass != ActiveRecordClass){
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(CurrentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            ARColumn *column = [[ARColumn alloc] initWithProperty:properties[i]];
            if(![ignoredFields containsObject:column.columnName]){
                [self.schemes addValue:column
                          toArrayNamed:[aRecordClass 
                                        performSelector:@selector(recordName)]];
            }
            [column release];
        }
        CurrentClass = class_getSuperclass(CurrentClass);
    }  
}

- (NSArray *)columnsForRecord:(Class)aRecordClass {
    return [[self.schemes valueForKey:[aRecordClass performSelector:@selector(recordName)]] allObjects];
}

@end
