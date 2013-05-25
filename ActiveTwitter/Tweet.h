//
// Created by Alex Denisov on 25.05.13.
// Copyright (c) 2013 okolodev.org. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <ActiveRecord.h>

@interface Tweet : ActiveRecord

@property (nonatomic, copy) NSString *text;

@end