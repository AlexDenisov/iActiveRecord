//
//  ARValidation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 30.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARValidator.h"
#import "ARValidation.h"
#import "ActiveRecord_Private.h"

#warning move to extension

@interface ARValidator ()
{
    NSMutableSet *validations;
}

+ (instancetype)sharedInstance;

- (BOOL)isValidOnSave:(id)aRecord;
- (BOOL)isValidOnUpdate:(id)aRecord;

- (void)registerValidator:(Class)aValidator
                forRecord:(NSString *)aRecord
                  onField:(NSString *)aField;

@end

@implementation ARValidator

- (instancetype)init {
    self = [super init];
    if (self) {
        validations = [NSMutableSet new];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)registerValidator:(Class)aValidator
                forRecord:(NSString *)aRecord
                  onField:(NSString *)aField
{
    ARValidation *validation = [[ARValidation alloc] initWithRecord:aRecord
                                                              field:aField
                                                          validator:aValidator];
    [validations addObject:validation];
}

- (BOOL)isValidOnSave:(ActiveRecord *)aRecord {
    BOOL valid = YES;
    NSString *recordName = [aRecord performSelector:@selector(recordName)];
    for (int i = 0; i < validations.count; i++) {
        ARValidation *validation = [[validations allObjects] objectAtIndex:i];
        if ([validation.record isEqualToString:recordName]) {
            id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
            BOOL result = [validator validateField:validation.field
                                          ofRecord:aRecord];
            
            if (!result) {
                NSString *errMsg = @"";
                if ([validator respondsToSelector:@selector(errorMessage)]) {
                    errMsg = [validator errorMessage];
                }
                ARError *error = [[ARError alloc] initWithModel:validation.record
                                                       property:validation.field
                                                          error:errMsg];
                [aRecord performSelector:@selector(addError:)
                              withObject:error];
                valid  = NO;
            }
        }
    }
    return valid;
}

- (BOOL)isValidOnUpdate:(ActiveRecord *)aRecord {
    BOOL valid = YES;
    NSString *recordName = [aRecord performSelector:@selector(recordName)];
    for (ARValidation *validation in validations) {
        if ([validation.record isEqualToString:recordName]) {
            ARColumn *column = [aRecord columnNamed:validation.field];
            if ([[aRecord changedColumns] containsObject:column]) {
                id<ARValidatorProtocol> validator = [[validation.validator alloc] init];
                BOOL result = [validator validateField:validation.field
                                              ofRecord:aRecord];
                
                if (!result) {
                    NSString *errMsg = @"";
                    if ([validator respondsToSelector:@selector(errorMessage)]) {
                        errMsg = [validator errorMessage];
                    }
                    ARError *error = [[ARError alloc] initWithModel:validation.record
                                                           property:validation.field
                                                              error:errMsg];
                    [aRecord performSelector:@selector(addError:)
                                  withObject:error];
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

+ (void)registerValidator:(Class)aValidator
                forRecord:(NSString *)aRecord
                  onField:(NSString *)aField
{
    [[self sharedInstance] registerValidator:aValidator
                                   forRecord:aRecord
                                     onField:aField];
}

@end
