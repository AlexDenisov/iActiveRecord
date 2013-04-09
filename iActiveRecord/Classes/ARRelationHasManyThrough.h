//
//  ARRelationHasManyThrough.h
//  iActiveRecord
//
//  Created by Alex Denisov on 26.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARBaseRelationship.h"

@interface ARRelationHasManyThrough : ARBaseRelationship

- (id)initWithRecord:(NSString *)aRecordName 
       throughRecord:(NSString *)aThroughRecord
            relation:(NSString *)aRelation 
           dependent:(ARDependency)aDependency;

@end
