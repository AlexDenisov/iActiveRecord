//
//  ARRelationHasManyThrough.m
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARRelationHasManyThrough.h"

@implementation ARRelationHasManyThrough

@synthesize relation;
@synthesize dependency;
@synthesize record;
@synthesize throughRecord;

- (id)initWithRecord:(NSString *)aRecordName 
       throughRecord:(NSString *)aThroughRecord
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency
{
    self = [super init];
    if(self != nil){
        self.throughRecord = aThroughRecord;
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

@end
