//
//  DynamicRecord.h
//  iActiveRecord
//
//  Created by Alex Denisov on 14.06.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ActiveRecord.h"

@interface DynamicRecord : ActiveRecord

@property (nonatomic, 
           retain, 
           getter = customGetter, 
           setter = customSetter:) NSString *customProperty;
@property (nonatomic, copy) NSString *defaultProperty;

@property (nonatomic, copy) NSString *copiedString;
@property (nonatomic, retain) NSString *retainedString;
@property (nonatomic, assign) NSString *assignedString;

@end
