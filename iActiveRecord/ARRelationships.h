//
//  ARRelationships.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSString+lowercaseFirst.h"

#import <objc/runtime.h>

#define belonsg_to_imp(class, accessor) \
    - (id)accessor{\
        NSString *class_name = @""#class"";\
        return [self performSelector:@selector(belongsTo:) withObject:class_name];\
    }\
    - (void)set##class:(ActiveRecord *)aRecord {\
        NSString *aClassName = @""#class"";\
        objc_msgSend(self, sel_getUid("setRecord:belongsTo:"), aRecord, aClassName);\
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
        return objc_msgSend(self, sel_getUid("hasManyRecords:"), class_name);\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        objc_msgSend(self, sel_getUid("addRecord:"), aRecord);\
    }\
    - (void)remove##relative_class:(ActiveRecord *)aRecord {\
        objc_msgSend(self, sel_getUid("removeRecord:"), aRecord);\
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
        return objc_msgSend(self, sel_getUid("hasMany:through:"), className, relativeClassName);\
    }\
    - (void)add##relative_class:(ActiveRecord *)aRecord {\
        NSString *className = @""#relative_class"";\
        NSString *relativeClassName = @""#relationship"";\
        objc_msgSend(self, sel_getUid("addRecord:ofClass:through:"), aRecord, className, relativeClassName);\
    }\
    - (void)remove##relative_class:(ActiveRecord *)aRecord {\
        NSString *className = @""#relationship"";\
        objc_msgSend(self, sel_getUid("removeRecord:through:"), aRecord, className);\
    }


