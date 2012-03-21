//
//  ARObjectProperty.m
//  iActiveRecord
//
//  Created by Alex Denisov on 11.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARObjectProperty.h"

@implementation ARObjectProperty

@synthesize propertyName;
@synthesize propertyType;
@synthesize propertyAttributes;


- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if(nil != self){
        self.propertyName = [NSString stringWithUTF8String:property_getName(property)];
        self.propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *type = [[self.propertyAttributes componentsSeparatedByString:@","] objectAtIndex:0];
        self.propertyType = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"T@\""]];
    }
    return self;
}

@end
