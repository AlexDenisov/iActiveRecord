//
//  ARColumn_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARColumn.h"
#import <objc/runtime.h>
#import "ARPropertyType.h"

@class ActiveRecord;

@interface ARColumn ()
{
    @public
    NSString *_columnName;
    Class _columnClass;
    NSString *_setter;
    NSString *_getter;
    ARPropertyType _propertyType;
    char *_columnKey;
}

@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) Class columnClass;
@property (nonatomic, copy, readwrite) NSString *setter;
@property (nonatomic, copy, readwrite) NSString *getter;
@property (nonatomic, readwrite) ARPropertyType propertyType; 

- (id)initWithProperty:(objc_property_t)property;

- (void)setPropertyTypeFromAttribute:(const char *)anAttribute;
- (void)setSetterFromAttribute:(const char *)anAttribute;
- (void)setGetterFromAttribute:(const char *)anAttribute;

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord;
- (const char *)sqlType;

@end
