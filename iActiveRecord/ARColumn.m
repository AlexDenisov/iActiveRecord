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
#import "ARPropertyType.h"

@implementation ARColumn

@synthesize columnName = _columnName;
@synthesize columnClass = _columnClass;
@synthesize getter = _getter;
@synthesize setter = _setter;
@synthesize propertyType = _propertyType;

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if(nil != self){
        BOOL dynamic = NO;
        self.propertyType = ARPropertyTypeAssign;
        
        const char *propertyName = property_getName(property);
        int propertyNameLength = strlen(propertyName);
        _columnKey = calloc(propertyNameLength, sizeof(char));
        strcpy(_columnKey, propertyName);
        
        self->_columnName = [[NSString alloc] initWithUTF8String:_columnKey];
        
//        self.columnName = [NSString stringWithUTF8String:property_getName(property)];
        //  set default setter/getter
        [self setSetterFromAttribute:NULL];
        [self setGetterFromAttribute:NULL];
        uint attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        for(int i=0;i<attributesCount;i++){
            switch (attributes[i].name[0]) {
                case 'T': 
                    [self setPropertyTypeFromAttribute:attributes[i].value];
                    break;
                case 'C': 
                    self.propertyType = ARPropertyTypeCopy;
                    break;
                case '&': 
                    self.propertyType = ARPropertyTypeRetain;
                    break;
                case 'G': // Getter
                    [self setGetterFromAttribute:attributes[i].value];
                    break;
                case 'S': // Setter
                    [self setSetterFromAttribute:attributes[i].value];
                    break;
                case 'D': // is dynamic property?
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
    free(_columnKey);
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
        self.getter = [NSString stringWithFormat:@"%@", self.columnName];
    } 
}

- (NSString *)sqlValueForRecord:(ActiveRecord *)aRecord {
    id value =  objc_getAssociatedObject(aRecord,
                                         self->_columnKey); //[aRecord valueForColumn:self];
    return [value performSelector:@selector(toSql)];
}

- (const char *)sqlType {
    return (const char*)[self.columnClass performSelector:@selector(sqlType)];
}

@end
