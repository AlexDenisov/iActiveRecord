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

@interface ARValidator ()
{
    NSMutableSet *validations;
}

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
    @synchronized(self){
        if(_instance == nil){
            _instance = [[ARValidator alloc] init];
        }
        return _instance;
    }
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
    NSString *recordName = [aRecord performSelector:@selector(recordName)];
    for(int i=0;i<validations.count;i++){
        ARValidation *validation = [[validations allObjects] objectAtIndex:i];
        if([validation.record isEqualToString:recordName]){
            id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
            BOOL result = [validator validateField:validation.field
                                          ofRecord:aRecord];
            
            if(!result){
                NSString *errMsg = @"";
                if([validator respondsToSelector:@selector(errorMessage)]){
                    errMsg = [validator errorMessage];
                }
                ARError *error = [[ARError alloc] initWithModel:validation.record
                                                       property:validation.field
                                                          error:errMsg];
                [aRecord performSelector:@selector(addError:) 
                              withObject:error];
                [error release];
                valid  = NO;
            }
            [validator release];
        }
    }
    return valid;
}

- (BOOL)isValidOnUpdate:(id)aRecord {
    BOOL valid = YES;
    NSString *recordName = [aRecord performSelector:@selector(recordName)];
    for(ARValidation *validation in validations){
        if([validation.record isEqualToString:recordName]){
            if([[aRecord changedFields] containsObject:validation.field]){
                id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
                BOOL result = [validator validateField:validation.field
                                              ofRecord:aRecord];
                
                if(!result){
                    NSString *errMsg = @"";
                    if([validator respondsToSelector:@selector(errorMessage)]){
                        errMsg = [validator errorMessage];
                    }
                    ARError *error = [[ARError alloc] initWithModel:validation.record
                                                           property:validation.field
                                                              error:errMsg];
                    [aRecord performSelector:@selector(addError:) 
                                  withObject:error];
                    [error release];
                    valid  = NO;
                }
                [validator release];
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
