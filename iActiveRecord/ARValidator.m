//
//  ARValidation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 30.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARValidator.h"
#import "ARValidation.h"
#import "ActiveRecord.h"

@interface ARValidator (Private)

+ (id)sharedInstance;

- (BOOL)isValidOnSave:(id)aRecord;
- (BOOL)isValidOnUpdate:(id)aRecord;

- (void)registerValidator:(Class)aValidator 
                forRecord:(NSString *)aRecord 
                  onField:(NSString *)aField;

@end

@implementation ARValidator

- (id)init {
    self = [super init];
    if(self){
        validations = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc {
    [validations release];
    [super dealloc];
}

+ (id)sharedInstance {
    if(_instance == nil){
        _instance = [[ARValidator alloc] init];
    }
    return _instance;
}

- (void)registerValidator:(Class)aValidator 
                forRecord:(NSString *)aRecord 
                  onField:(NSString *)aField
{
    ARValidation *validation = [[ARValidation alloc] initWithRecord:aRecord
                                                              field:aField
                                                          validator:aValidator];
    [validations addObject:validation];
    [validation release];
}

- (BOOL)isValidOnSave:(id)aRecord {
    BOOL valid = YES;
    NSString *className = [aRecord performSelector:@selector(className)];
    for(ARValidation *validation in validations){
        if([validation.record isEqualToString:className]){
            id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
            BOOL result = [validator validateField:validation.field
                                          ofRecord:aRecord];
            [validator release];
            if(!result){
                valid  = NO;
            }
        }
    }
    return valid;
}

- (BOOL)isValidOnUpdate:(id)aRecord {
    BOOL valid = YES;
    NSString *className = [aRecord performSelector:@selector(className)];
    for(ARValidation *validation in validations){
        if([validation.record isEqualToString:className]){
            if([[aRecord changedFields] containsObject:validation.field]){
                id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
                BOOL result = [validator validateField:validation.field
                                              ofRecord:aRecord];
                [validator release];
                if(!result){
                    valid  = NO;
                }
            }
        }
    }
    return valid;
}

#pragma mark - Public

+ (BOOL)isValidOnSave:(id)aRecord {
    return [[self sharedInstance] isValidOnSave:aRecord];
}

+ (BOOL)isValidOnUpdate:(id)aRecord {
    return [[self sharedInstance] isValidOnUpdate:aRecord];
}

static ARValidator *_instance = nil;

+ (void)registerValidator:(Class)aValidator 
                forRecord:(NSString *)aRecord 
                  onField:(NSString *)aField
{
    [[self sharedInstance] registerValidator:aValidator
                                   forRecord:aRecord
                                     onField:aField];
}

@end
