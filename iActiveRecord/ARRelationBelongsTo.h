//
//  ARBelongsToRelation.h
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AREnum.h"

@interface ARRelationBelongsTo : NSObject

@property (nonatomic, copy) NSString *record;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, readwrite) ARDependency dependency;

- (id)initWithRecord:(NSString *)aRecordName 
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency;

@end
