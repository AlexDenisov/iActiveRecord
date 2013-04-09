//
//  Animal.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Animal.h"
#import "AnimalValidator.h"

@implementation Animal

@dynamic name;
@dynamic state;
@dynamic title;

validation_do(
    validate_field_with_validator(name, AnimalValidator)
)

@end
