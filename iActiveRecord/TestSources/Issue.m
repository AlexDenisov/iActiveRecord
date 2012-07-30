//
//  Issue.m
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Issue.h"

@implementation Issue

@synthesize projectId;
@synthesize title;

belongs_to_imp(Project, project, ARDependencyNullify)

@end
