//
//  ARRelationships.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+lowercaseFirst.h"
 
#define BELONGS_TO_IMP(class, accessor) \
    - (id)accessor{\
        NSString *class_name = @""#class"";\
        return [self belongsTo:class_name];\
    }

#define BELONGS_TO_DEC(class, accessor) \
    - (id)accessor;

#define HAS_MANY_DEC(relative_class, accessor)\
    - (ARLazyFetcher *)accessor;\
    - (void)add##relative_class:(ActiveRecord *)aRecord;

#define HAS_MANY_IMP(relative_class, accessor) \
    - (ARLazyFetcher *)accessor{\
        NSString *class_name = @""#relative_class"";\
        return [self hasManyRecords:class_name];\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        [self addRecord:aRecord];\
    }\

#define HAS_MANY_THROUGH_DEC(relative_class, relationship, accessor) \
    - (ARLazyFetcher *)accessor;\
    - (void)add##relative_class:(ActiveRecord *)aRecord;

#define HAS_MANY_THROUGH_IMP(relative_class, relationship, accessor) \
    - (ARLazyFetcher *)accessor\
    {\
        NSString *className = @""#relative_class"";\
        NSString *relativeClassName = @""#relationship"";\
        return [self hasMany:className through:relativeClassName];\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        NSString *className = @""#relative_class"";\
        NSString *relativeClassName = @""#relationship"";\
        [self addRecord:aRecord ofClass:className through:relativeClassName];\
    }\


