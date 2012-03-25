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

#define validation_helper \
    static NSMutableSet *uniqueFields = nil;\
    static NSMutableSet *presenceFields = nil;

#define validation_do(validations) \
    validation_helper\
    + (void)initValidations {\
        if(nil == uniqueFields)\
            uniqueFields = [[NSMutableSet alloc] init];\
        if(nil == presenceFields)\
            presenceFields = [[NSMutableSet alloc] init];\
    validations\
}
