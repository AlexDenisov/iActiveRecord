//
//  ARColumn.m
//  iActiveRecord
//
//  Created by Alex Denisov on 29.04.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARColumn.h"
#import "ARColumn_Private.h"
#import "NSString+uppercaseFirst.h"

@implementation ARColumn

@synthesize columnName;
@synthesize columnClass;
@synthesize getter;
@synthesize setter;

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if(nil != self){
        self.columnName = [NSString stringWithUTF8String:property_getName(property)];
        //  set default setter/getter
        [self setSetterFromAttribute:NULL];
        [self setGetterFromAttribute:NULL];
        uint attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        for(int i=0;i<attributesCount;i++){
            NSLog(@"%s %s", attributes[i].name, attributes[i].value);
            switch (attributes[i].name[0]) {
                case 'T': // type
                    [self setPropertyTypeFromAttribute:attributes[i].value];
                    break;
                case 'R': // readonly
                    break;
                case 'C': // copy 
                    break;
                case '&': // retain
                    break;
                case 'N': // nonatomic 
                    break;
                case 'G': // custom getter
                    [self setGetterFromAttribute:attributes[i].value];
                    break;
                case 'S': // custom setter
                    [self setSetterFromAttribute:attributes[i].value];
                    break;
                case 'D': // dynamic 
                    break;
                default: 
                break;
            }
        }
        free(attributes);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"Column: %@ %@", 
            NSStringFromClass(self.columnClass),
            self.columnName];
}

- (BOOL)isEqual:(id)object {
    ARColumn *right = (ARColumn *)object;
    BOOL result = YES;
    if(![self.columnName isEqualToString:right.columnName]){
        result = NO;
    }
    if(self.columnClass != right.columnClass){
        result = NO;
    }
    return result;
}

- (void)dealloc {
    self.columnClass = nil;
    self.columnName = nil;
    self.setter = nil;
    self.getter = nil;
    [super dealloc];
}

#pragma mark - Property Meta Parser

- (void)setPropertyTypeFromAttribute:(const char *)anAttribute {
    char *type = NULL;
    //  classes described as @"ClassName"
    if (anAttribute[0] == '@') {
        unsigned long length = strlen(anAttribute);

    }
}

//  use custom setter if anAttribute == nil
- (void)setSetterFromAttribute:(const char *)anAttribute {
    if(anAttribute){
        self.setter = [NSString stringWithUTF8String:anAttribute];
    }else {
        self.setter = [NSString stringWithFormat:@"set%@:", [self.columnName uppercaseFirst]];
    }
}

//  use custom getter if anAttribute == nil
- (void)setGetterFromAttribute:(const char *)anAttribute {
   if(anAttribute){
        self.getter = [NSString stringWithUTF8String:anAttribute];
    }else {
        self.getter = [NSString stringWithFormat:self.columnName];
    } 
}

@end
