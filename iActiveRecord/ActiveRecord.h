//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

#import "ARRelationshipsHelper.h"
#import "ARValidationsHelper.h"
#import "ARValidatableProtocol.h"
#import "ARMigrationsHelper.h"
#import "ARLazyFetcher.h"
#import "NSArray+objectsAccessors.h"
#import "ARWhereStatement.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import "AREnum.h"
#import "ARValidatorProtocol.h"
#import "ARException.h"

typedef void (^ARTransactionBlock)();


#define ar_rollback \
    [ARException raise];

@interface ActiveRecord : NSObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

- (void)markAsNew;

- (BOOL)isValid;
- (NSArray *)errors;
- (void)addError:(ARError *)anError;
- (NSArray *)changedFields;

+ (id)newRecord;
- (BOOL)save;
- (BOOL)update;
- (void)dropRecord;

+ (NSInteger)count;
+ (NSArray *)allRecords;
+ (ARLazyFetcher *)lazyFetcher;

+ (void)dropAllRecords;

+ (void)registerDatabaseName:(NSString *)aDbName useDirectory:(ARStorageDirectory)aDirectory;
+ (void)clearDatabase;
+ (void)disableMigrations;
+ (void)transaction:(ARTransactionBlock)aTransactionBlock;

@end
