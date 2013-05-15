//
//  ARError.m
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARError.h"

@implementation ARError

- (instancetype)initWithModel:(NSString *)aModel
                     property:(NSString *)aProperty
                        error:(NSString *)anError
{
    self = [super init];
    if (self) {
        self.modelName = aModel;
        self.propertyName = aProperty;
        self.errorName = anError;
    }
    return self;
}

@end
