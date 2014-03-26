//
// Created by James Whitfield on 3/26/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveRecord;

typedef enum {
    kPersistentQueueEntityTypeNone = 0,
    kPersistentQueueEntityTypeBelongsTo = 1,
    kPersistentQueueEntityTypeHasMany = 2,
    kPersistentQueueEntityTypeHasManyThrough = 3
} PersistentQueueEntityType;


@interface ARPersistentQueueEntity : NSObject

@property(nonatomic, retain) ActiveRecord *record;
@property(nonatomic, retain) NSString *relation;
@property(nonatomic, retain) NSString *relationshipClass;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, assign) PersistentQueueEntityType type;

@end