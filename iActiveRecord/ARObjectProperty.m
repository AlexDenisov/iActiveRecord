//
//  ARObjectProperty.m
//  iActiveRecord
//
//  Created by mls on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

- (const char *)sqltype {
    if([self.propertyType isEqualToString:@"NSNumber"]){
        return "integer";
    }
    if([self.propertyType isEqualToString:@"NSString"]){
        return "text";
    }
    return NULL;
}

@end
