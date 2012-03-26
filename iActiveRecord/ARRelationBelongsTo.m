//
//  ARBelongsToRelation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARRelationBelongsTo.h"

@implementation ARRelationBelongsTo

@synthesize relation;
@synthesize dependency;
@synthesize record;

- (id)initWithRecord:(NSString *)aRecordName 
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency
{
    self = [super init];
    if(self != nil){
        self.record = aRecordName;
        self.relation = aRelation;
        self.dependency = aDependency;
    }
    return self;
}

- (void)dealloc {
    self.record = nil;
    self.relation = nil;
    [super dealloc];
}

@end
