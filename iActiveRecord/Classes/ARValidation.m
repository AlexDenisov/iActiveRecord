//
//  ARValidation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARValidation.h"

@implementation ARValidation

- (instancetype)initWithRecord:(NSString *)aRecord
                         field:(NSString *)aField
                     validator:(Class)aValidator
{
    self = [super init];
    if (self) {
        self.record = aRecord;
        self.field  = aField;
        self.validator = aValidator;
    }
    return self;
}
#warning Reimplement with `hash`
- (BOOL)isEqual:(id)object {
    ARValidation *otherObject = (ARValidation *)object;
    if (![self.record isEqualToString:otherObject.record]) {
        return NO;
    }
    if (![self.field isEqualToString:otherObject.field]) {
        return NO;
    }
    if (![self.validator isEqual:otherObject.validator]) {
        return NO;
    }
    return YES;
}

@end
