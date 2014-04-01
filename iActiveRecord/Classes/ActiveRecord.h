//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

#import "ARRelationshipsHelper.h"
#import "ARValidationsHelper.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import "AREnum.h"
#import "ARValidatorProtocol.h"
#import "ARException.h"
#import "ARIndicesMacroHelper.h"
#import "ARConfiguration.h"

@class ARConfiguration;

typedef void (^ARTransactionBlock)();
typedef void (^ARConfigurationBlock) (ARConfiguration *config);

#define ar_rollback \
    [ARException raise];

@interface ActiveRecord : NSObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

- (void)markAsNew;

- (BOOL)isDirty;
- (BOOL)isValid;
- (NSArray *)errors;
- (void)addError:(ARError *)anError;
- (void)addErrors:(NSArray*) errors;

+ (instancetype)newRecord;
+ (instancetype) new: (NSDictionary *) values;
+ (instancetype) create: (NSDictionary *) values;
- (BOOL)save;
- (BOOL)update;
- (void)dropRecord;

+ (NSInteger)count;
+ (NSArray *)allRecords;
+ (ARLazyFetcher *)lazyFetcher;

+ (void)dropAllRecords;

+ (void)clearDatabase;
+ (void)transaction:(ARTransactionBlock)aTransactionBlock;

+ (void)applyConfiguration:(ARConfigurationBlock)configBlock;

#pragma mark - TableName

+ (NSString *)recordName;

@end
