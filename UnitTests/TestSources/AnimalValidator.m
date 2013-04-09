//
//  AnimalValidator.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "AnimalValidator.h"

@implementation AnimalValidator

- (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
    NSString *aValue = [aRecord valueForKey:aField];
    BOOL valid = [aValue isEqualToString:@"animal"];
    return valid;
}

@end
