//
//  Animal.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Animal.h"
#import "AnimalValidator.h"

@implementation Animal

@synthesize name;
@synthesize state;

validation_do(
    validate_field_with_validator(name, AnimalValidator)
)

@end
