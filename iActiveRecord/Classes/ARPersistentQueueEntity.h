//
// Created by James Whitfield on 3/26/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AREnum.h"
@class ActiveRecord;



@interface ARPersistentQueueEntity : NSObject

@property(nonatomic, retain) ActiveRecord *record;
@property(nonatomic, retain) NSString *relation;
@property(nonatomic, retain) NSString *relationshipClass;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, assign) ARRelationType type;

+ (instancetype)entityBelongingToRecord:(ActiveRecord *)aRecord relation:(NSString *)aRelation;
+ (instancetype)entityHavingManyRecord:(ActiveRecord *)aRecord ofClass:(NSString *)aClassname
                               through:(NSString *)aRelationshipClassName;
+ (instancetype)entityHavingManyRecord:(ActiveRecord *)aRecord;
@end