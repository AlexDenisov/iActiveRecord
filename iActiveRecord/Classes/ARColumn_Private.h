//
//  ARColumn_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <objc/runtime.h>
#import "ARColumn.h"
#import "ARColumnType.h"

@class ActiveRecord;

@interface ARColumn ()
{
    @public
    char *_columnKey;
}

@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) NSString *setter;
@property (nonatomic, copy, readwrite) NSString *getter;
@property (nonatomic, strong, readwrite) Class columnClass;
@property (nonatomic, strong, readwrite) Class recordClass;
@property (nonatomic, readwrite) objc_AssociationPolicy associationPolicy;
@property (nonatomic, readwrite) ARColumnType columnType;

- (instancetype)initWithProperty:(objc_property_t)property ofClass:(Class)aClass;

- (BOOL)setPropertyTypeFromAttribute:(const char *)anAttribute;
- (void)setSetterFromAttribute:(const char *)anAttribute;
- (void)setGetterFromAttribute:(const char *)anAttribute;

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord;
- (const char *)sqlType;

@end
