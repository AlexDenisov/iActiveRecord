//
//  ARBaseRelationship.m
//  iActiveRecord
//
//  Created by Alex Denisov on 22.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARBaseRelationship.h"

@implementation ARBaseRelationship

@synthesize relation;
@synthesize dependency;
@synthesize record;
@synthesize throughRecord;

- (id)initWithRecord:(NSString *)aRecordName 
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency
{
    self = [super init];
    if(self != nil){
        self.throughRecord = nil;
        self.record = aRecordName;
        self.relation = aRelation;
        self.dependency = aDependency;
    }
    return self;
}

- (void)dealloc {
    self.record = nil;
    self.relation = nil;
    self.throughRecord = nil;
    [super dealloc];
}

- (ARRelationType)type {
    return ARRelationTypeNone;
}

@end
