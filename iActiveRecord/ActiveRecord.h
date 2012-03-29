//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

#import "ARRelationships.h"
#import "ARValidations.h"
#import "ARValidatableProtocol.h"
#import "ARMigrationsHelper.h"
#import "ARLazyFetcher.h"
#import "NSArray+objectsAccessors.h"
#import "ARWhereStatement.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import "AREnum.h"

@interface ActiveRecord : NSObject
{
@private
    BOOL isNew;
    NSMutableSet *errorMessages;
    NSMutableSet *changedFields;
}

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

- (void)markAsNew;

- (BOOL)isValid;
- (NSArray *)errorMessages;

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

@end
