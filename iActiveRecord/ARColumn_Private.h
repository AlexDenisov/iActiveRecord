//
//  ARColumn_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARColumn.h"
#import <objc/runtime.h>

@interface ARColumn ()
@property (nonatomic, copy, readwrite) NSString *columnName;
@property (nonatomic, copy, readwrite) Class columnClass;

- (id)initWithProperty:(objc_property_t)property;
@end
