//
//  ARColumn_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <objc/runtime.h>
#import "ARColumn.h"

@class ActiveRecord;

@interface ARColumn ()
{
    @public
    NSString *_columnName;
    Class _columnClass;
    NSString *_setter;
    NSString *_getter;
    objc_AssociationPolicy _associationPolicy;
    char *_columnKey;
}

@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) Class columnClass;
@property (nonatomic, copy, readwrite) NSString *setter;
@property (nonatomic, copy, readwrite) NSString *getter;
@property (nonatomic, readwrite) objc_AssociationPolicy associationPolicy;

- (id)initWithProperty:(objc_property_t)property;

- (void)setPropertyTypeFromAttribute:(const char *)anAttribute;
- (void)setSetterFromAttribute:(const char *)anAttribute;
- (void)setGetterFromAttribute:(const char *)anAttribute;

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord;
- (const char *)sqlType;

@end
