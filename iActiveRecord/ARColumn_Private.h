//
//  ARColumn_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <objc/runtime.h>
#import "ARColumn.h"
#import "ARColumnType.h"

@class ActiveRecord;

@interface ARColumn ()
{
    @public
    NSString *_columnName;
    Class _columnClass;
    Class _recordClass;
    NSString *_setter;
    NSString *_getter;
    objc_AssociationPolicy _associationPolicy;
    char *_columnKey;
    ARColumnType _columnType;
}

@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) Class columnClass;
@property (nonatomic, copy, readwrite) Class recordClass;
@property (nonatomic, copy, readwrite) NSString *setter;
@property (nonatomic, copy, readwrite) NSString *getter;
@property (nonatomic, readwrite) objc_AssociationPolicy associationPolicy;
@property (nonatomic, readwrite) ARColumnType columnType;

- (id)initWithProperty:(objc_property_t)property ofClass:(Class)aClass;

- (BOOL)setPropertyTypeFromAttribute:(const char *)anAttribute;
- (void)setSetterFromAttribute:(const char *)anAttribute;
- (void)setGetterFromAttribute:(const char *)anAttribute;

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord;
- (const char *)sqlType;

@end
