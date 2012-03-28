//
//  ARValidationUniqueness.m
//  iActiveRecord
//
//  Created by Alex Denisov on 28.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARValidationUniqueness.h"

@implementation ARValidationUniqueness

@synthesize field;
@synthesize record;

- (id)initWithRecord:(NSString *)aRecord 
               field:(NSString *)aField
{
    self = [super init];
    if(self != nil){
        self.record = aRecord;
        self.field  =aField;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    ARValidationUniqueness *otherObject = (ARValidationUniqueness *)object;
    if(![self.record isEqualToString:otherObject.record]){
        return NO;
    }
    if(![self.field isEqualToString:otherObject.field]){
        return NO;
    }
    return YES;
}

@end
