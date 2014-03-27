//
//  ActiveRecord_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 13.05.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ActiveRecord.h"

@class ARLazyFetcher;
@class ARError;
@class ARColumn;

@interface ActiveRecord ()
{
    @private
    BOOL isNew;
    NSMutableSet *errors;
    NSMutableSet *_changedColumns;
}

@property (nonatomic,strong) NSMutableSet *belongsToPersistentQueue;
@property (nonatomic,strong) NSMutableSet *hasManyPersistentQueue;
@property (nonatomic,strong) NSMutableSet *hasManyThroughRelationsQueue;

#pragma mark - Lazy Persistent Helpers
- (BOOL)isNewRecord;
- (BOOL)hasQueuedRelationships;
- (BOOL)persistQueuedManyRelationships;

#pragma mark - Validations Declaration

+ (void)initializeValidators;
+ (void)validateUniquenessOfField:(NSString *)aField;
+ (void)validatePresenceOfField:(NSString *)aField;
+ (void)validateField:(NSString *)aField withValidator:(NSString *)aValidator;

#pragma mark - Resetting

- (void)resetErrors;
- (void)resetChanges;

- (NSArray *)columns;
+ (NSArray *)columns;

#pragma mark - Relationships

#pragma mark BelongsTo

- (id)belongsTo:(NSString *)aClassName;
- (void)setRecord:(ActiveRecord *)aRecord belongsTo:(NSString *)aRelation;
- (BOOL)persistRecord:(ActiveRecord *)aRecord belongsTo:(NSString *)aRelation;

#pragma mark HasMany

- (ARLazyFetcher *)hasManyRecords:(NSString *)aClassName;
- (void)addRecord:(ActiveRecord *)aRecord;
- (void)removeRecord:(ActiveRecord *)aRecord;
- (BOOL)persistRecord:(ActiveRecord *)aRecord;
#pragma mark HasManyThrough

- (ARLazyFetcher *)hasMany:(NSString *)aClassName
                   through:(NSString *)aRelationsipClassName;
- (void)addRecord:(ActiveRecord *)aRecord
          ofClass:(NSString *)aClassname
          through:(NSString *)aRelationshipClassName;
- (void)removeRecord:(ActiveRecord *)aRecord through:(NSString *)aClassName;
- (BOOL)persistRecord:(ActiveRecord *)aRecord
              ofClass:(NSString *)aClassname
              through:(NSString *)aRelationshipClassName;
#pragma mark - register relationships

+ (void)registerRelationships;
+ (void)registerBelongs:(NSString *)aSelectorName;
+ (void)registerHasMany:(NSString *)aSelectorName;
+ (void)registerHasManyThrough:(NSString *)aSelectorName;

+ (NSArray *)relationships;
- (NSArray *)relationships;

#pragma mark - private before filter

- (void)privateAfterDestroy;

#pragma mark - Column getters

+ (ARColumn *)columnNamed:(NSString *)aColumnName;
- (ARColumn *)columnNamed:(NSString *)aColumnName;

+ (ARColumn *)columnWithSetterNamed:(NSString *)aSetterName;
- (ARColumn *)columnWithSetterNamed:(NSString *)aSetterName;

+ (ARColumn *)columnWithGetterNamed:(NSString *)aGetterName;
- (ARColumn *)columnWithGetterNamed:(NSString *)aGetterName;

- (NSSet *)changedColumns;

#pragma mark - Dynamic Properties

+ (void)initializeDynamicAccessors;
- (void)setValue:(id)aValue forColumn:(ARColumn *)aColumn;
- (id)valueForColumn:(ARColumn *)aColumn;

#pragma mark - Indices support

+ (void)initializeIndices;
+ (void)addIndexOn:(NSString *)aField;

- (NSString *)recordName;

@end
