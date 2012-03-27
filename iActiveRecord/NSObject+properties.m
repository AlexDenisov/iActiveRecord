//
//  NSObject+properties.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSObject+properties.h"
#import <objc/runtime.h>
#import "ARObjectProperty.h"

@implementation NSObject (properties)

+ (NSArray *)activeRecordProperties {
    NSMutableArray *propertiesArray = [NSMutableArray array]; 
    Class ActiveRecordClass = NSClassFromString(@"NSObject");
    id CurrentClass = self;//objc_getClass([[[self class] description] UTF8String]);
    while(nil != CurrentClass && CurrentClass != ActiveRecordClass){
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(CurrentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            ARObjectProperty *objectProperty = [[ARObjectProperty alloc] initWithProperty:properties[i]];
            [propertiesArray addObject:objectProperty];
            [objectProperty release];
        }
        CurrentClass = class_getSuperclass(CurrentClass);
    }
    return propertiesArray;
}

+ (NSString *)propertyClassNameWithPropertyName:(NSString *)aName {
    NSArray *properties = [[self class] activeRecordProperties];
    for(ARObjectProperty *p in properties){
        if([p.propertyName isEqualToString:aName]){
            return p.propertyType;
        }
    }
    return nil;
}

@end
