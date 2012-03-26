//
//  ARRelationHasManyThrough.h
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AREnum.h"

@interface ARRelationHasManyThrough : NSObject

@property (nonatomic, copy) NSString *record;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, copy) NSString *throughRecord;
@property (nonatomic, readwrite) ARDependency dependency;


- (id)initWithRecord:(NSString *)aRecordName 
       throughRecord:(NSString *)aThroughRecord
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency;

@end
