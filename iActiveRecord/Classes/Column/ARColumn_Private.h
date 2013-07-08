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

#import "IColumnInternal.h"

@class ActiveRecord;

@interface ARColumn ()

@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) NSString *setter;
@property (nonatomic, copy, readwrite) NSString *getter;
@property (nonatomic, strong, readwrite) Class columnClass;
@property (nonatomic, strong, readwrite) Class recordClass;
@property (nonatomic, readwrite) ARColumnType columnType;

@property (nonatomic, readwrite) AR::IColumnInternal *internal;


- (BOOL)setPropertyTypeFromAttribute:(const char *)anAttribute;
- (void)setSetterFromAttribute:(const char *)anAttribute;
- (void)setGetterFromAttribute:(const char *)anAttribute;


@end
