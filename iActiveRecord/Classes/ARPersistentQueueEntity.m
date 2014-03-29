//
// Created by James Whitfield on 3/26/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "ARPersistentQueueEntity.h"
#import "ActiveRecord.h"



@implementation ARPersistentQueueEntity {
}

- (id)init {
    self = [super init];
    if (self) {
      self.type = ARRelationTypeNone;
    }

    return self;
}

+ (instancetype)entityBelongingToRecord:(ActiveRecord *)aRecord relation:(NSString *)aRelation {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.relation = aRelation;
    entity.type = ARRelationTypeBelongsTo;
    return entity;
}

+ (instancetype)entityHavingManyRecord:(ActiveRecord *)aRecord {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.type = ARRelationTypeHasMany;
    return entity;
}


+ (instancetype)entityHavingManyRecord:(ActiveRecord *)aRecord ofClass:(NSString *)aClassname
                               through:(NSString *)aRelationshipClassName {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.className = aClassname;
    entity.relationshipClass = aRelationshipClassName;
    entity.type = ARRelationTypeHasManyThrough;
    return entity;
}


- (NSUInteger)hash {
    if(self.type != ARRelationTypeNone)
    switch (self.type) {
        case ARRelationTypeBelongsTo:
            return [self.relation hash];
        default:
            return [self.record hash];
    }

    return [super hash];
}

- (BOOL)isEqual:(id)other {

    if(self.type != ARRelationTypeNone)
        switch (self.type) {
            case ARRelationTypeBelongsTo:
                return [self.relation isEqual:other];
            default:
                return [self.record isEqual:other];
        }


    if (self.record)
        return [self.record isEqual:other];

    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return YES;
}


@end