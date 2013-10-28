//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ActiveRecord.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"
#import <objc/runtime.h>
#import "ARValidationsHelper.h"
#import "ARErrorHelper.h"
#import "ARDatabaseManager.h"

#import "ARRelationBelongsTo.h"
#import "ARRelationHasMany.h"
#import "ARRelationHasManyThrough.h"

#import "ARValidator.h"
#import "ARValidatorUniqueness.h"
#import "ARValidatorPresence.h"
#import "ARException.h"

#import "NSString+stringWithEscapedQuote.h"
#import "NSMutableDictionary+valueToArray.h"

#import "ActiveRecord_Private.h"
#import "ARSchemaManager.h"
#import "ARColumn.h"

#import "ARDynamicAccessor.h"
#import "ARConfiguration.h"

static NSMutableDictionary *relationshipsDictionary = nil;

@implementation ActiveRecord

@dynamic id;
@dynamic createdAt;
@dynamic updatedAt;

#pragma mark - Initialize

+ (void)initialize {
    [super initialize];
    [self initializeIndices];
    [[ARSchemaManager sharedInstance] registerSchemeForRecord:self];
    [self initializeValidators];
    [self initializeDynamicAccessors];
    [self registerRelationships];
}

#pragma mark - registering relationships

static NSMutableSet *belongsToRelations = nil;
static NSMutableSet *hasManyRelations = nil;
static NSMutableSet *hasManyThroughRelations = nil;

static NSString *registerBelongs = @"_ar_registerBelongsTo";
static NSString *registerHasMany = @"_ar_registerHasMany";
static NSString *registerHasManyThrough = @"_ar_registerHasManyThrough";

+ (void)registerRelationships {
    if (relationshipsDictionary == nil) {
        relationshipsDictionary = [NSMutableDictionary new];
    }
    uint count = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &count);
    for (int i = 0; i < count; i++) {
        NSString *selectorName = NSStringFromSelector(method_getName(methods[i]));
        if ([selectorName hasPrefix:registerBelongs]) {
            [self registerBelongs:selectorName];
            continue;
        }
        if ([selectorName hasPrefix:registerHasManyThrough]) {
            [self registerHasManyThrough:selectorName];
            continue;
        }
        if ([selectorName hasPrefix:registerHasMany]) {
            [self registerHasMany:selectorName];
            continue;
        }
    }
    free(methods);
}

+ (void)registerBelongs:(NSString *)aSelectorName {
    if (belongsToRelations == nil) {
        belongsToRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *relationName = [aSelectorName stringByReplacingOccurrencesOfString:registerBelongs
                                                                      withString:@""];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    ARDependency dependency = (ARDependency)[self performSelector:selector];
#pragma clang diagnostic pop
    ARRelationBelongsTo *relation = [[ARRelationBelongsTo alloc] initWithRecord:[self recordName]
                                                                       relation:relationName
                                                                      dependent:dependency];
    [relationshipsDictionary addValue:relation
                         toArrayNamed:[self recordName]];
}

+ (void)registerHasMany:(NSString *)aSelectorName {
    if (hasManyRelations == nil) {
        hasManyRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *relationName = [aSelectorName stringByReplacingOccurrencesOfString:registerHasMany
                                                                      withString:@""];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    ARDependency dependency = (ARDependency)[self performSelector:selector];
#pragma clang diagnostic pop
    ARRelationHasMany *relation = [[ARRelationHasMany alloc] initWithRecord:[self recordName]
                                                                   relation:relationName
                                                                  dependent:dependency];
    [relationshipsDictionary addValue:relation
                         toArrayNamed:[self recordName]];
}

+ (void)registerHasManyThrough:(NSString *)aSelectorName {
    if (hasManyThroughRelations == nil) {
        hasManyThroughRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *records = [aSelectorName stringByReplacingOccurrencesOfString:registerHasManyThrough
                                                                 withString:@""];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    ARDependency dependency = (ARDependency)[self performSelector:selector];
#pragma clang diagnostic pop
    NSArray *components = [records componentsSeparatedByString:@"_ar_"];
    NSString *relationName = [components objectAtIndex:0];
    NSString *throughRelationname = [components objectAtIndex:1];
    ARRelationHasManyThrough *relation = [[ARRelationHasManyThrough alloc] initWithRecord:[self recordName]
                                                                            throughRecord:throughRelationname
                                                                                 relation:relationName
                                                                                dependent:dependency];
    [relationshipsDictionary addValue:relation
                         toArrayNamed:[self recordName]];
}

#pragma mark - private before filter

- (void)privateAfterDestroy {
    for (ARBaseRelationship *relation in [self relationships]) {
        
        if (relation.dependency != ARDependencyDestroy) {
            continue;
        }
        
        switch ([relation type]) {
            case ARRelationTypeBelongsTo:
            {
                [[self belongsTo:relation.relation] dropRecord];
            } break;
            case ARRelationTypeHasManyThrough:
            {
                [[[self hasMany:relation.relation
                        through:relation.throughRecord] fetchRecords]
                 makeObjectsPerformSelector:@selector(dropRecord)];
            } break;
            case ARRelationTypeHasMany:
            {
                [[[self hasManyRecords:relation.relation]
                  fetchRecords]
                 makeObjectsPerformSelector:@selector(dropRecord)];
            } break;
            default:
                break;
        }
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.createdAt = self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    return self;
}

- (void)dealloc {
    for (ARColumn *column in self.columns) {
        objc_setAssociatedObject(self, column.columnKey,
                                 nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    self.id = nil;
    self.updatedAt = nil;
    self.createdAt = nil;
}

- (void)markAsNew {
    isNew = YES;
}

#pragma mark -

- (void)resetChanges {
    [_changedColumns removeAllObjects];
}

- (void)resetErrors {
    errors = nil;
}

- (void)addError:(ARError *)anError {
    if (nil == errors) {
        errors = [NSMutableSet new];
    }
    [errors addObject:anError];
}

#pragma mark -

+ (NSArray *)relationships {
    return [relationshipsDictionary objectForKey:[self recordName]];
}

- (NSArray *)relationships {
    return [[self class] relationships];
}

+ (NSString *)recordName {
    return [self description];
}
- (NSString *)recordName {
    return [[self class] recordName];
}

+ (instancetype)newRecord {
    ActiveRecord *record = [[self alloc] init];
    [record markAsNew];
    return record;
}

#pragma mark - Fetchers

+ (NSArray *)allRecords {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:[self class]];
    return [fetcher fetchRecords];
}

+ (ARLazyFetcher *)lazyFetcher {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:[self class]];
    return fetcher;
}

#pragma mark - Validations

+ (void)initializeValidators {
    //  nothing goes there
}

+ (void)validateUniquenessOfField:(NSString *)aField {
    [ARValidator registerValidator:[ARValidatorUniqueness class]
                         forRecord:[self recordName]
                           onField:aField];
}

+ (void)validatePresenceOfField:(NSString *)aField {
    [ARValidator registerValidator:[ARValidatorPresence class]
                         forRecord:[self recordName]
                           onField:aField];
}

+ (void)validateField:(NSString *)aField withValidator:(NSString *)aValidator {
    [ARValidator registerValidator:NSClassFromString(aValidator)
                         forRecord:[self recordName]
                           onField:aField];
}

- (BOOL)isValid {
    BOOL valid = YES;
    [self resetErrors];
    if (isNew) {
        valid = [ARValidator isValidOnSave:self];
    }else {
        valid = [ARValidator isValidOnUpdate:self];
    }
    return valid;
}

- (NSArray *)errors {
    return [errors allObjects];
}

#pragma mark - Save/Update

- (BOOL)save {
    if (!isNew) {
        return [self update];
    }
    if (![self isValid]) {
        return NO;
    }
    NSInteger newRecordId = [[ARDatabaseManager sharedManager] saveRecord:self];
    if (newRecordId) {
        self.id = [NSNumber numberWithInteger:newRecordId];
        isNew = NO;
        [_changedColumns removeAllObjects];
        return YES;
    }
    return NO;
}

- (BOOL)update {
    if (![self isValid]) {
        return NO;
    }
    if (isNew) {
        return [self save];
    }
    NSInteger result = [[ARDatabaseManager sharedManager] updateRecord:self];
    if (result) {
        [_changedColumns removeAllObjects];
        return YES;
    }
    return NO;
}

+ (NSInteger)count {
    return [[ARDatabaseManager sharedManager] countOfRecordsWithName:[[self class] description]];
}

#pragma mark - Relationships

#pragma mark BelongsTo

- (id)belongsTo:(NSString *)aClassName {
    NSString *selectorString = [NSString stringWithFormat:@"%@Id", [aClassName lowercaseFirst]];
    SEL selector = NSSelectorFromString(selectorString);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSNumber *rec_id = [self performSelector:selector];
#pragma clang diagnostic pop
    
    if (rec_id == nil) {
        return nil;
    }
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    [fetcher where:@"id = %@", rec_id, nil];
    NSArray *records = [fetcher fetchRecords];
    return records.count ? [records objectAtIndex:0] : nil;
}

- (void)setRecord:(ActiveRecord *)aRecord belongsTo:(NSString *)aRelation {
    NSString *relId = [NSString stringWithFormat:
                       @"%@Id", [aRelation lowercaseFirst]];
    ARColumn *column = [self columnNamed:relId];
    [self setValue:aRecord.id
         forColumn:column];
    [self update];
}

#pragma mark HasMany

- (void)addRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[self recordName] lowercaseFirst]];
    ARColumn *column = [aRecord columnNamed:relationIdKey];
    [aRecord setValue:self.id forColumn:column];
    [aRecord save];
}

- (void)removeRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[self recordName] lowercaseFirst]];
    ARColumn *column = [aRecord columnNamed:relationIdKey];
    [aRecord setValue:nil forColumn:column];
    [aRecord save];
}

- (ARLazyFetcher *)hasManyRecords:(NSString *)aClassName {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    NSString *selfId = [NSString stringWithFormat:@"%@Id", [[self class] description]];
    [fetcher where:@"%@ = %@", selfId, self.id, nil];
    return fetcher;
}

#pragma mark HasManyThrough

- (ARLazyFetcher *)hasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName {
    NSString *relId = [NSString stringWithFormat:@"%@Id", [[self recordName] lowercaseFirst]];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    [fetcher join:NSClassFromString(aRelationsipClassName)];
    [fetcher where:@"%@.%@ = %@", aRelationsipClassName, relId, self.id, nil];
    return fetcher;
}

- (void)addRecord:(ActiveRecord *)aRecord
          ofClass:(NSString *)aClassname
          through:(NSString *)aRelationshipClassName
{
    Class RelationshipClass = NSClassFromString(aRelationshipClassName);
    
    NSString *currentId = [NSString stringWithFormat:@"%@ID", [self recordName]];
    NSString *relId = [NSString stringWithFormat:@"%@ID", [aRecord recordName]];
    ARLazyFetcher *fetcher = [RelationshipClass lazyFetcher];
    [fetcher where:@"%@ = %@ AND %@ = %@", currentId, self.id, relId, aRecord.id, nil];
    if ([fetcher count] != 0) {
        return;
    }
    NSString *currentIdSelectorString = [NSString stringWithFormat:@"set%@Id:", [[self class] description]];
    NSString *relativeIdSlectorString = [NSString stringWithFormat:@"set%@Id:", aClassname];
    
    SEL currentIdSelector = NSSelectorFromString(currentIdSelectorString);
    SEL relativeIdSelector = NSSelectorFromString(relativeIdSlectorString);
    ActiveRecord *relationshipRecord = [RelationshipClass newRecord];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [relationshipRecord performSelector:currentIdSelector withObject:self.id];
    [relationshipRecord performSelector:relativeIdSelector withObject:aRecord.id];
#pragma clang diagnostic pop
    [relationshipRecord save];
}

- (void)removeRecord:(ActiveRecord *)aRecord through:(NSString *)aClassName {
    Class relationsClass = NSClassFromString(aClassName);
    ARLazyFetcher *fetcher = [relationsClass lazyFetcher];
    NSString *currentId = [NSString stringWithFormat:@"%@ID", [self recordName]];
    NSString *relId = [NSString stringWithFormat:@"%@ID", [aRecord recordName]];
    [fetcher where:@"%@ = %@ AND %@ = %@", currentId, self.id, relId, aRecord.id, nil];
    NSArray *records = [fetcher fetchRecords];
    ActiveRecord *record = records.count ? [records objectAtIndex:0] : nil;
    [record dropRecord];
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *descr = [NSMutableString stringWithFormat:@"%@\n", [self recordName]];
    for (ARColumn *column in [self columns]) {
        [descr appendFormat:@"%@ => %@;", column.columnName, [self valueForColumn:column]];
    }
    return descr;
}

#pragma mark - Drop records

+ (void)dropAllRecords {
    [[self allRecords] makeObjectsPerformSelector:@selector(dropRecord)];
}

- (void)dropRecord {
    [[ARDatabaseManager sharedManager] dropRecord:self];
    [self privateAfterDestroy];
}

#pragma mark - Clear database

+ (void)clearDatabase {
    [[ARDatabaseManager sharedManager] clearDatabase];
}

#pragma mark - Transactions

+ (void)transaction:(ARTransactionBlock)aTransactionBlock {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [[ARDatabaseManager sharedManager] executeSqlQuery:"BEGIN"];
        @try {
            aTransactionBlock();
            [[ARDatabaseManager sharedManager] executeSqlQuery:"COMMIT"];
        }
        @catch (ARException *exception) {
            [[ARDatabaseManager sharedManager] executeSqlQuery:"ROLLBACK"];
        }
    });
}

#pragma mark - Record Columns

- (NSArray *)columns {
    return [[self class] columns];
}

+ (NSArray *)columns {
    return [[ARSchemaManager sharedInstance] columnsForRecord:self];
}

- (ARColumn *)columnNamed:(NSString *)aColumnName {
    return [[self class] columnNamed:aColumnName];
}

#warning refactor

+ (ARColumn *)columnNamed:(NSString *)aColumnName {
    NSArray *columns = [self columns];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"columnName = %@", aColumnName];
    NSArray *filteredColumns = [columns filteredArrayUsingPredicate:predicate];
    return filteredColumns.count ? [filteredColumns objectAtIndex:0] : nil;
}

+ (ARColumn *)columnWithSetterNamed:(NSString *)aSetterName {
    NSArray *columns = [self columns];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"setter = %@", aSetterName];
    NSArray *filteredColumns = [columns filteredArrayUsingPredicate:predicate];
    return filteredColumns.count ? [filteredColumns objectAtIndex:0] : nil;
}
- (ARColumn *)columnWithSetterNamed:(NSString *)aSetterName {
    return [[self class] columnWithSetterNamed:aSetterName];
}

+ (ARColumn *)columnWithGetterNamed:(NSString *)aGetterName {
    NSArray *columns = [self columns];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"getter = %@", aGetterName];
    NSArray *filteredColumns = [columns filteredArrayUsingPredicate:predicate];
    return filteredColumns.count ? [filteredColumns objectAtIndex:0] : nil;
}
- (ARColumn *)columnWithGetterNamed:(NSString *)aGetterName {
    return [[self class] columnWithGetterNamed:aGetterName];
}

- (NSSet *)changedColumns {
    return _changedColumns;
}

#pragma mark - Dynamic Properties

+ (void)initializeDynamicAccessors {
    for (ARColumn *column in [self columns]) {
        [ARDynamicAccessor addAccessorForColumn:column];
    }
}

//  KVO-bycycle/Observer
- (void)setValue:(id)aValue forColumn:(ARColumn *)aColumn {
    //    if ([[self recordName] isEqualToString:@"PrimitiveModel"]) {
    //        NSLog(@"%@ %@", aValue, aColumn.columnName);
    //    }
    if (aColumn == nil) {
        return;
    }
    if (_changedColumns == nil) {
        _changedColumns = [NSMutableSet new];
    }
    
    id oldValue = objc_getAssociatedObject(self, aColumn.columnKey);
    if ( (oldValue == nil && aValue == nil) || ([oldValue isEqual:aValue]) ) {
        return;
    }
    
    objc_setAssociatedObject(self,
                             aColumn.columnKey,
                             nil,
                             aColumn.associationPolicy);
    
    objc_setAssociatedObject(self,
                             aColumn.columnKey,
                             aValue,
                             aColumn.associationPolicy);
    
    [_changedColumns addObject:aColumn];
}

- (id)valueForColumn:(ARColumn *)aColumn {
    id object = objc_getAssociatedObject(self, aColumn.columnKey);
    return object;
}

- (id)valueForUndefinedKey:(NSString *)aKey {
    ARColumn *column = [self columnNamed:aKey];
    if (column == nil) {
        return [super valueForUndefinedKey:aKey];
    }else {
        return [self valueForColumn:column];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)aKey {
    ARColumn *column = [self columnNamed:aKey];
    if (column == nil) {
        [super setValue:value forUndefinedKey:aKey];
    }else {
        [self setValue:value
             forColumn:column];
    }
}

#pragma mark - Indices

+ (void)initializeIndices {
    //  nothing goes there
}

+ (void)addIndexOn:(NSString *)aField {
    [[ARSchemaManager sharedInstance] addIndexOnColumn:aField
                                              ofRecord:self];
}

#pragma mark - Configuration

+ (void)applyConfiguration:(ARConfigurationBlock)configBlock {
    NSAssert(configBlock, @"ARConfigurationBlock should not be nil");
    
    ARConfiguration *config = [ARConfiguration new];
    configBlock(config);
    ARDatabaseManager *manager = [ARDatabaseManager sharedManager];
    [manager applyConfiguration:config];
}

@end
