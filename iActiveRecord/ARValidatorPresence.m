//
//  ARValidatorPresence.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARValidatorPresence.h"
#import "ARErrorHelper.h"

@implementation ARValidatorPresence

- (NSString *)errorMessage {
    return kARFieldCantBeBlank;
}

- (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
    NSString *aValue = [aRecord valueForKey:aField];
    BOOL presence = (aValue != nil) && ([aValue length]);
    return presence;
}

@end
