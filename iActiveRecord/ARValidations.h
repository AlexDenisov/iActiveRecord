//
//  ARValidations.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.02.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

#define validate_uniqueness_of(aField)\
    [self performSelector:@selector(validateUniquenessOfField:) withObject:@""#aField""];

#define validate_presence_of(aField)\
    [self performSelector:@selector(validatePresenceOfField:) withObject:@""#aField""];\

#define validation_do(validations) \
    + (void)initValidations {\
    validations\
}
