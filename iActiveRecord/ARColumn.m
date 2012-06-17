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
#import "ActiveRecord_Private.h"

@implementation ARColumn

@synthesize columnName;
@synthesize columnClass;
@synthesize getter;
@synthesize setter;

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if(nil != self){
        BOOL dynamic = NO;
        self.columnName = [NSString stringWithUTF8String:property_getName(property)];
        //  set default setter/getter
        [self setSetterFromAttribute:NULL];
        [self setGetterFromAttribute:NULL];
        uint attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        for(int i=0;i<attributesCount;i++){
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
                case 'D':
                    dynamic = YES;
                    break;
                default: 
                break;
            }
        }
        free(attributes);
        if(!dynamic){
            return nil;
        }
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
        unsigned long length = strlen(anAttribute)-3;
        type = calloc(length, sizeof(char));
        strncpy(type, anAttribute+2, length);
        self.columnClass = [objc_getClass(type) class];
        free(type);
    }
}

//  use custom setter if anAttribute == nil/NULL
- (void)setSetterFromAttribute:(const char *)anAttribute {
    if(anAttribute){
        self.setter = [NSString stringWithUTF8String:anAttribute];
    }else {
        self.setter = [NSString stringWithFormat:@"set%@:", [self.columnName uppercaseFirst]];
    }
}

//  use custom getter if anAttribute == nil/NULL
- (void)setGetterFromAttribute:(const char *)anAttribute {
   if(anAttribute){
        self.getter = [NSString stringWithUTF8String:anAttribute];
    }else {
        self.getter = [NSString stringWithFormat:self.columnName];
    } 
}

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord {
    id value = [aRecord valueForColumn:self];
    return [value performSelector:@selector(toSql)];
}

@end
