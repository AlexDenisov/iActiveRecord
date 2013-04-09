//
//  ARBaseRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AREnum.h"

@interface ARBaseRelationship : NSObject

@property (nonatomic, copy) NSString *record;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, readwrite) ARDependency dependency;
@property (nonatomic, copy) NSString *throughRecord;

- (id)initWithRecord:(NSString *)aRecordName 
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency;

- (ARRelationType)type;

@end
