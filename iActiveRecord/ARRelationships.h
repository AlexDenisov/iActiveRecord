//
//  ARRelationships.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+lowercaseFirst.h"
 
#define belonsg_to_imp(class, accessor) \
    - (id)accessor{\
        NSString *class_name = @""#class"";\
        return [self performSelector:@selector(belongsTo:) withObject:class_name];\
    }\
    - (void)set##class:(ActiveRecord *)aRecord {\
        NSString *aClassName = @""#class"";\
        [self performSelector:@selector(setRecord:belongsTo:) withObject:aRecord withObject:aClassName];\
    }

#define belongs_to_dec(class, accessor) \
    - (id)accessor;\
    - (void)set##class:(ActiveRecord *)aRecord;


#define has_many_dec(relative_class, accessor)\
    - (ARLazyFetcher *)accessor;\
    - (void)add##relative_class:(ActiveRecord *)aRecord;\
    - (void)remove##relative_class:(ActiveRecord *)aRecord;

#define has_many_imp(relative_class, accessor) \
    - (ARLazyFetcher *)accessor{\
        NSString *class_name = @""#relative_class"";\
        return [self hasManyRecords:class_name];\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        [self addRecord:aRecord];\
    }\
    - (void)remove##relative_class:(ActiveRecord *)aRecord {\
        [self removeRecord:aRecord];\
    }

#define has_many_through_dec(relative_class, relationship, accessor) \
    - (ARLazyFetcher *)accessor;\
    - (void)add##relative_class:(ActiveRecord *)aRecord;\
    - (void)remove##relative_class:(ActiveRecord *)aRecord;

#define has_many_through_imp(relative_class, relationship, accessor) \
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
    - (void)remove##relative_class:(ActiveRecord *)aRecord {\
        NSString *className = @""#relationship"";\
        [self removeRecord:aRecord through:className];\
    }


