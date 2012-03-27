//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARRelationships.h"
#import "ARValidations.h"
#import "ARValidatableProtocol.h"
#import "ARMigrationsHelper.h"
#import "ARLazyFetcher.h"
#import "NSArray+objectsAccessors.h"
#import "ARWhereStatement.h"
#import "ARObjectProperty.h"
#import "ARDatabaseManager.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import <objc/message.h>
#import "AREnum.h"

@interface ActiveRecord : NSObject
{
@private
    BOOL isNew;
    NSMutableSet *errorMessages;
    NSMutableSet *changedFields;
}

@property (nonatomic, retain) NSNumber *id;

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

@end
