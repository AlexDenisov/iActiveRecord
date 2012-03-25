//
//  ARError.m
//  iActiveRecord
//
//  Created by Alex Denisov on 25.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARError.h"

@implementation ARError

@synthesize propertyName;
@synthesize modelName;
@synthesize errorName;

- (id)initWithModel:(NSString *)aModel 
           property:(NSString *)aProperty 
              error:(NSString *)anError 
{
    self = [super init];
    if(self != nil){
        self.modelName = aModel;
        self.propertyName = aProperty;
        self.errorName = anError;
    }
    return self;
}

- (void)dealloc {
    self.propertyName = nil;
    self.modelName = nil;
    self.errorName = nil;
    [super dealloc];
}

@end
