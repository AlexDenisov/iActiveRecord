//
//  ARColumn.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ARColumnType.h"

@class ActiveRecord;

@interface ARColumn : NSObject
{
//@public
//    char *_columnKey;
}

@property (nonatomic, copy, readonly) NSString *columnName;
@property (nonatomic, strong, readonly) Class columnClass;
@property (nonatomic, strong, readonly) Class recordClass;
@property (nonatomic, copy, readonly) NSString *getter;
@property (nonatomic, copy, readonly) NSString *setter;
@property (nonatomic, readwrite, getter = isDynamic) BOOL dynamic;
@property (nonatomic, readonly) ARColumnType columnType;

@property (nonatomic, readwrite) objc_AssociationPolicy associationPolicy;

- (instancetype)initWithProperty:(objc_property_t)property ofClass:(Class)aClass;
- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord;
- (const char *)sqlType;

- (const char *)columnKey;

@end
