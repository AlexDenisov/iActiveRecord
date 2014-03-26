//
// Created by James Whitfield on 3/26/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "ARPersistentQueueEntity.h"
#import "ActiveRecord.h"


@implementation ARPersistentQueueEntity {}
+ (instancetype) entityBelongingToRecord: (ActiveRecord *)aRecord relation:(NSString *)aRelation {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.relation = aRelation;
    entity.type = kPersistentQueueEntityTypeHasManyThrough;
    return entity;
}

+ (instancetype) entityHavingManyRecord: (ActiveRecord *)aRecord  {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.type = kPersistentQueueEntityTypeHasMany;

    return entity;
}


+ (instancetype) entityHavingManyRecord: (ActiveRecord *)aRecord ofClass:(NSString *)aClassname
                                                                 through:(NSString *)aRelationshipClassName  {

    ARPersistentQueueEntity *entity = [[self alloc] init];
    entity.record = aRecord;
    entity.className = aClassname;
    entity.relationshipClass = aRelationshipClassName;
    entity.type = kPersistentQueueEntityTypeHasManyThrough;
    return entity;
}


- (NSUInteger)hash {
    if(self.record)
        return [self.record hash];

    return [super hash];
}

- (BOOL)isEqual:(id)other {
    if(self.record)
        return [self.record isEqual:other];

    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return YES;
}


@end