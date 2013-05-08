//
//  ARRelationHasManyThrough.m
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARRelationHasManyThrough.h"

@implementation ARRelationHasManyThrough

@synthesize throughRecord;

- (instancetype)initWithRecord:(NSString *)aRecordName
                 throughRecord:(NSString *)aThroughRecord
                      relation:(NSString *)aRelation
                     dependent:(ARDependency)aDependency
{
    self = [super initWithRecord:aRecordName
            relation:aRelation
            dependent:aDependency];
    if (self) {
        self.throughRecord = aThroughRecord;
    }
    return self;
}

- (ARRelationType)type {
    return ARRelationTypeHasManyThrough;
}

@end
