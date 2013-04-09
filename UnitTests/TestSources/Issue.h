//
//  Issue.h
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ActiveRecord.h"

@interface Issue : ActiveRecord

@property (nonatomic, retain) NSNumber *projectId;
@property (nonatomic, copy) NSString *title;

belongs_to_dec(Project, project, ARDependencyNullify)

@end
