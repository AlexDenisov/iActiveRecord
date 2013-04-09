//
//  Issue.m
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Issue.h"

@implementation Issue

@dynamic projectId;
@dynamic title;

belongs_to_imp(Project, project, ARDependencyNullify)

@end
