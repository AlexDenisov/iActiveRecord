//
//  ARBaseRelationship.m
//  iActiveRecord
//
//  Created by Alex Denisov on 22.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARBaseRelationship.h"

@implementation ARBaseRelationship

- (instancetype)initWithRecord:(NSString *)aRecordName
                      relation:(NSString *)aRelation
                     dependent:(ARDependency)aDependency
{
    self = [super init];
    if (self) {
        self.throughRecord = nil;
        self.record = aRecordName;
        self.relation = aRelation;
        self.dependency = aDependency;
    }
    return self;
}

- (ARRelationType)type {
    return ARRelationTypeNone;
}

@end
