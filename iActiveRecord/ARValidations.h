//
//  ARValidations.h
//  iActiveRecord
//
//  Created by mls on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VALIDATE_UNIQUENESS_OF(aField)\
    [ActiveRecord validateField:(@""#aField"")\
                       asUnique:YES];

#define VALIDATE_PRESENCE_OF(aField)\
    [ActiveRecord validateField:(@""#aField"")\
                     asPresence:YES];

#define VALIDATION_HELPER \
    static NSMutableSet *uniqueFields = nil;\
    static NSMutableSet *presenceFields = nil;

#define VALIDATIONS_DO(validations) \
    VALIDATION_HELPER\
    + (void)initValidations {\
        if(nil == uniqueFields)\
            uniqueFields = [[NSMutableSet alloc] init];\
        if(nil == presenceFields)\
            presenceFields = [[NSMutableSet alloc] init];\
    validations\
}
