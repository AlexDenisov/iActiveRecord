//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ActiveRecord.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"
#import <objc/runtime.h>
#import "ARObjectProperty.h"
#import "ARValidations.h"
#import "ARValidatableProtocol.h"
#import "ARErrorHelper.h"
#import "ARMigrationsHelper.h"
#import "NSObject+properties.h"
#import "NSArray+objectsAccessors.h"
#import "NSString+quotedString.h"
#import "ARDatabaseManager.h"

#import "ARRelationBelongsTo.h"
#import "ARRelationHasMany.h"
#import "ARRelationHasManyThrough.h"
#import "ARObjectProperty.h"

#import "ARValidationUniqueness.h"
#import "ARValidationPresence.h"

@interface ActiveRecord (Private)

#pragma mark - Validations Declaration

+ (void)validateField:(NSString *)aField 
             asUnique:(BOOL)aUnique;
+ (void)validateField:(NSString *)aField 
           asPresence:(BOOL)aPresence;

+ (void)validateUniquenessOfField:(NSString *)aField;
+ (void)validatePresenceOfField:(NSString *)aField;

- (BOOL)validateOnSave;
- (BOOL)validateOnUpdate;
- (BOOL)validateUniqueness;
- (BOOL)validatePresence;
- (BOOL)isValidUniquenessOfField:(NSString *)aField;
- (BOOL)isValidPresenceOfField:(NSString *)aField;

- (void)resetErrors;
- (void)addError:(ARError *)anError;

+ (NSArray *)uniqueFields;
+ (NSArray *)presenceFields;

#pragma mark - SQLQueries

+ (const char *)sqlOnCreate;
+ (const char *)sqlOnDeleteAll;
- (const char *)sqlOnDelete;
- (const char *)sqlOnSave;
- (const char *)sqlOnUpdate;

#pragma mark - ObserveChanges

- (void)didChangeField:(NSString *)aField;

#pragma mark - IgnoreFields

+ (void)initIgnoredFields;
+ (void)ignoreField:(NSString *)aField;

#pragma mark - TableName

+ (NSString *)tableName;
- (NSString *)tableName;

+ (NSString *)className;
- (NSString *)className;

+ (NSArray *)tableFields;

#pragma mark - Relationships

#pragma mark BelongsTo

- (id)belongsTo:(NSString *)aClassName;
- (void)setRecord:(ActiveRecord *)aRecord belongsTo:(NSString *)aRelation;

#pragma mark HasMany

- (ARLazyFetcher *)hasManyRecords:(NSString *)aClassName;
- (void)addRecord:(ActiveRecord *)aRecord;
- (void)removeRecord:(ActiveRecord *)aRecord;

#pragma mark HasManyThrough

- (ARLazyFetcher *)hasMany:(NSString *)aClassName 
                   through:(NSString *)aRelationsipClassName;
- (void)addRecord:(ActiveRecord *)aRecord 
          ofClass:(NSString *)aClassname 
          through:(NSString *)aRelationshipClassName;
- (void)removeRecord:(ActiveRecord *)aRecord through:(NSString *)aClassName;

#pragma mark - register relationships

+ (void)registerRelationships;
+ (void)registerBelongs:(NSString *)aSelectorName;
+ (void)registerHasMany:(NSString *)aSelectorName;
+ (void)registerHasManyThrough:(NSString *)aSelectorName;

#pragma mark - private before filter

- (void)privateAfterDestroy;

@end

@implementation ActiveRecord

migration_helper

@synthesize id;
@synthesize createdAt;
@synthesize updatedAt;

#pragma mark - Initialize

+ (void)initialize {
    [super initialize];
    [self initIgnoredFields];
    if([self conformsToProtocol:@protocol(ARValidatableProtocol)]){
        [self performSelector:@selector(initValidations)];
    }
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
    uint count = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &count);
    for(int i=0;i<count;i++){
        NSString *selectorName = NSStringFromSelector(method_getName(methods[i]));
        if([selectorName hasPrefix:registerBelongs]){
            [self registerBelongs:selectorName];
            continue;
        }
        if([selectorName hasPrefix:registerHasManyThrough]){
            [self registerHasManyThrough:selectorName];
            continue;
        }
        if([selectorName hasPrefix:registerHasMany]){
            [self registerHasMany:selectorName];
            continue;
        }
    }
    free(methods);
}

+ (void)registerBelongs:(NSString *)aSelectorName {
    if(belongsToRelations == nil){
        belongsToRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *relationName = [aSelectorName stringByReplacingOccurrencesOfString:registerBelongs
                                                                 withString:@""];
    ARDependency dependency = (ARDependency)[self performSelector:selector];
    ARRelationBelongsTo *relation = [[ARRelationBelongsTo alloc] initWithRecord:[self className]
                                                                       relation:relationName
                                                                      dependent:dependency];
    [belongsToRelations addObject:relation];
    [relation release];
} 

+ (void)registerHasMany:(NSString *)aSelectorName {
    if(hasManyRelations == nil){
        hasManyRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *relationName = [aSelectorName stringByReplacingOccurrencesOfString:registerHasMany
                                                                      withString:@""];
    ARDependency dependency = (ARDependency)[self performSelector:selector];
    ARRelationHasMany *relation = [[ARRelationHasMany alloc] initWithRecord:[self className]
                                                                       relation:relationName
                                                                      dependent:dependency];
    [hasManyRelations addObject:relation];
    [relation release];
}

+ (void)registerHasManyThrough:(NSString *)aSelectorName {
    if(hasManyThroughRelations == nil){
        hasManyThroughRelations = [NSMutableSet new];
    }
    SEL selector = NSSelectorFromString(aSelectorName);
    NSString *records = [aSelectorName stringByReplacingOccurrencesOfString:registerHasManyThrough
                                                                 withString:@""];
    ARDependency dependency = (ARDependency)[self performSelector:selector];
    NSArray *components = [records componentsSeparatedByString:@"_ar_"];
    NSString *relationName = [components objectAtIndex:0];
    NSString *throughRelationname = [components objectAtIndex:1];
    ARRelationHasManyThrough *relation = [[ARRelationHasManyThrough alloc] initWithRecord:[self className]
                                                                            throughRecord:throughRelationname
                                                                                 relation:relationName
                                                                                dependent:dependency];
    [hasManyThroughRelations addObject:relation];
    [relation release];
}

#pragma mark - private before filter

#warning REFACTOR!!!

- (void)privateAfterDestroy {
    for(ARRelationBelongsTo *relation in belongsToRelations){
        if([relation.record isEqualToString:[self className]]){
            switch (relation.dependency) {
                case ARDependencyDestroy:
                {
                    ActiveRecord *record = [self belongsTo:relation.relation];
                    [record dropRecord];
                }break;
                    
                default:
                    break;
            }
        }
    }
    for(ARRelationHasMany *relation in hasManyRelations){
        if([relation.record isEqualToString:[self className]]){
            switch (relation.dependency) {
                case ARDependencyDestroy:
                {
                    NSArray *records = [[self hasManyRecords:relation.relation] fetchRecords];
                    [records makeObjectsPerformSelector:@selector(dropRecord)];
                }break;
                    
                default:
                    break;
            }
        }
    }
    for(ARRelationHasManyThrough *relation in hasManyThroughRelations){
        if([relation.record isEqualToString:[self className]]){
            switch (relation.dependency) {
                case ARDependencyDestroy:
                {
                    NSArray *records = [[self hasMany:relation.relation
                                             through:relation.throughRecord] fetchRecords];
                    [records makeObjectsPerformSelector:@selector(dropRecord)];
                }break;
                    
                default:
                    break;
            }
        }
    }
}

#pragma mark - IgnoreFields

- (id)init {
    self = [super init];
    if(nil != self){
        self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
        self.createdAt = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    return self;    
}

- (void)dealloc {
    self.id = nil;
    [errorMessages release];
    [changedFields release];
    [super dealloc];
}

- (void)markAsNew {
    isNew = YES;
}

#pragma mark - ObserveChanges

- (void)didChangeField:(NSString *)aField {
    if([ignoredFields containsObject:aField]){
        return;
    }
    if(nil == changedFields){
        changedFields = [NSMutableSet new];
    }
    [changedFields addObject:aField];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self didChangeField:key];
    [super setValue:value forKey:key];
}

+ (void)initIgnoredFields {
}

+ (void)ignoreField:(NSString *)aField {
    if(nil == ignoredFields){
        ignoredFields = [[NSMutableSet alloc] init];
    }
    [ignoredFields addObject:aField];
}

#pragma mark - 

- (void)resetErrors {
    [errorMessages release];
    errorMessages = nil;
}

- (void)addError:(ARError *)anError {
    if(nil == errorMessages){
        errorMessages = [NSMutableSet new];
    }
    [errorMessages addObject:anError];
}

- (void)initialize {
    
}

#pragma mark - SQLQueries

+ (const char *)sqlOnCreate {
    [self initIgnoredFields];
    NSMutableString *sqlString = [NSMutableString stringWithFormat:
                                  @"create table %@(id integer primary key unique ", 
                                  [[self tableName] quotedString]];
    NSArray *properties = [self activeRecordProperties];
    if([properties count] == 0){
        return NULL;
    }
    Class propertyClass = nil;
    for(ARObjectProperty *property in [self tableFields]){
        if(![property.propertyName isEqualToString:@"id"]){
            propertyClass = NSClassFromString(property.propertyType);
            [sqlString appendFormat:@", %@ %s", 
             [property.propertyName quotedString], 
            [propertyClass performSelector:@selector(sqlType)]];
        }
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

- (const char *)sqlOnDelete {
    NSString *sqlString = [NSString stringWithFormat:
                           @"delete from %@ where id = %@", 
                           [[self tableName] quotedString], 
                           self.id];
    return [sqlString UTF8String];
}

- (const char *)sqlOnSave {
    NSArray *properties = [[self class] tableFields];
    if([properties count] == 0){
        return NULL;
    }
    
    ARObjectProperty *property = nil;
    NSMutableArray *existedProperties = [NSMutableArray new];
    for(property in properties){
        id value = [self valueForKey:property.propertyName];
        if(nil != value){
            [existedProperties addObject:property];
        }
    }
    if([existedProperties count] == 0){
        [existedProperties release];
        return NULL;
    }
    
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"INSERT INTO %@(", 
                                  [[self tableName] quotedString]];
    NSMutableString *sqlValues = [NSMutableString stringWithFormat:@" VALUES("];
    
    int index = 0;
    property = [existedProperties objectAtIndex:index++];
    id propertyValue = [self valueForKey:property.propertyName];
    if(propertyValue == nil){
        propertyValue = @"";
    }
    [sqlString appendFormat:@"%@", [property.propertyName quotedString]];
    [sqlValues appendFormat:@"%@", [[propertyValue performSelector:@selector(toSql)] quotedString]];
    
    for(;index < [existedProperties count];index++){
        property = [existedProperties objectAtIndex:index];
        id propertyValue = [self valueForKey:property.propertyName];
        if(propertyValue == nil){
            propertyValue = @"";
        }
        [sqlString appendFormat:@", %@", [property.propertyName quotedString]];
        [sqlValues appendFormat:@", %@", [[propertyValue performSelector:@selector(toSql)] quotedString]];
    }
    [existedProperties release];
    [sqlValues appendString:@") "];
    [sqlString appendString:@") "];
    [sqlString appendString:sqlValues];
    return [sqlString UTF8String];
}

- (const char *)sqlOnUpdate {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", 
                                  [[self tableName] quotedString]];
    NSArray *updatedValues = [changedFields allObjects];
    NSInteger index = 0;
    NSString *propertyName = [updatedValues objectAtIndex:index++];
    id propertyValue = [self valueForKey:propertyName];
    [sqlString appendFormat:@"%@=%@", [propertyName quotedString], 
     [[propertyValue performSelector:@selector(toSql)] quotedString]];
   
    for(;index<[updatedValues count];index++){
        propertyName = [updatedValues objectAtIndex:index++];
        propertyValue = [self valueForKey:propertyName];
        [sqlString appendFormat:@", %@=%@", [propertyName quotedString], 
         [[propertyValue performSelector:@selector(toSql)] quotedString]];
    }
    [sqlString appendFormat:@" WHERE id = %@", self.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnDeleteAll {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", [[self tableName] quotedString]];
    return [sql UTF8String];
}

#pragma mark - 

+ (NSString *)tableName {
    return [self className];//[NSString stringWithFormat:@"ar%@", [[self class] description]];
}

- (NSString *)tableName {
    return [[self class] tableName];
}

+ (NSString *)className {
    return [self description];
}
- (NSString *)className {
    return [[self class] className];
}

+ (id)newRecord {
    Class RecordClass = [self class];
    ActiveRecord *record = [[RecordClass alloc] init];
    [record markAsNew];
    return record;
}

#pragma mark - Fetchers

+ (NSArray *)allRecords {
    ARLazyFetcher *fetcher = [[[ARLazyFetcher alloc] initWithRecord:[self class]] autorelease];
    return [fetcher fetchRecords];
}

+ (ARLazyFetcher *)lazyFetcher {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:[self class]];
    return [fetcher autorelease];
}

#pragma mark - Equal

- (BOOL)isEqualToRecord:(ActiveRecord *)anOtherRecord {
    if(nil == anOtherRecord){
        return NO;
    }
    NSArray *properties = [[self class] activeRecordProperties];
    for(ARObjectProperty *property in properties){
        id lValue = [self valueForKey:property.propertyName];
        id rValue = [anOtherRecord valueForKey:property.propertyName];
        if( ![lValue isEqual:rValue] ){
            return NO;
        }
    }
    return YES;
}


#pragma mark - Validations

static NSMutableSet *uniqueValidations = nil;
static NSMutableSet *presenceValidations = nil;

+ (void)validateUniquenessOfField:(NSString *)aField {
    [self validateField:aField asUnique:YES];
}

+ (void)validatePresenceOfField:(NSString *)aField {
    [self validateField:aField asPresence:YES];
}

//  boolean parameter is deprecated, should be removed
+ (void)validateField:(NSString *)aField asUnique:(BOOL)aUnique {
    if(nil == uniqueValidations){
        uniqueValidations = [NSMutableSet new];
    }
    ARValidationUniqueness *validation = [[ARValidationUniqueness alloc] initWithRecord:[self className] 
                                                                                  field:aField];
    [uniqueValidations addObject:validation];
    [validation release];
}

+ (void)validateField:(NSString *)aField asPresence:(BOOL)aPresence {
    if(nil == presenceValidations){
        presenceValidations = [NSMutableSet new];
    }
    ARValidationPresence *validation = [[ARValidationPresence alloc] initWithRecord:[self className] 
                                                                              field:aField];
    [presenceValidations addObject:validation];
    [validation release];
}

+ (NSArray *)uniqueFields {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"self.record = %@", 
                              [self className]];
    return [[uniqueValidations allObjects] filteredArrayUsingPredicate:predicate];

}

+ (NSArray *)presenceFields {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"self.record = %@", 
                              [self className]];
    return [[presenceValidations allObjects] filteredArrayUsingPredicate:predicate];
}

- (BOOL)isValid {
    BOOL valid = YES;
    [self resetErrors];
    if(isNew){
        valid = [self validateOnSave];              
    }else{
        valid = [self validateOnUpdate];
    }
    return valid;
}

- (BOOL)isValidPresenceOfField:(NSString *)aField {
    NSString *aValue = [self valueForKey:aField];
    if(aValue == nil || [aValue length] == 0){
        ARError *error = [[ARError alloc] initWithModel:[self className]
                                               property:aField
                                                  error:kARFieldCantBeBlank];
        [self addError:error];
        return NO;
    }
    return YES;
}

- (BOOL)isValidUniquenessOfField:(NSString *)aField {
    NSString *recordName = [[self class] description];
    id aValue = [self valueForKey:aField];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(recordName)];
    [fetcher whereField:aField
           equalToValue:aValue];
    NSInteger count = [fetcher count];
    [fetcher release];
    if(count){
        ARError *error = [[ARError alloc] initWithModel:[self className]
                                               property:aField
                                                  error:kARFieldAlreadyExists];
        [self addError:error];
        return NO;
    }
    return YES;
}

- (NSArray *)errorMessages {
    return [errorMessages allObjects];
}

- (BOOL)validateOnSave {
    if(![self conformsToProtocol:@protocol(ARValidatableProtocol)]){
        return YES;
    }
    return ([self validatePresence] && [self validateUniqueness]);
}

- (BOOL)validateOnUpdate {
    if(![self conformsToProtocol:@protocol(ARValidatableProtocol)]){
        return YES;
    }
    BOOL valid = YES;
    for(NSString *aField in changedFields){
        ARValidationUniqueness *unique = [[ARValidationUniqueness alloc] initWithRecord:[self className]
                                                                                  field:aField];
        ARValidationPresence *presence = [[ARValidationPresence alloc] initWithRecord:[self className]
                                                                                  field:aField];
        
        if([[[self class] presenceFields] containsObject:unique]){
            if(![self isValidPresenceOfField:aField]){
                valid = NO;
            }
        }
        if([[[self class] presenceFields] containsObject:presence]){
            if(![self isValidUniquenessOfField:aField]){
                valid = NO;
            }
        }
    }
    return valid;
}

- (BOOL)validateUniqueness {
    BOOL valid = YES;
    for(ARValidationUniqueness *unique in [[self class] uniqueFields]){
        if(![self isValidUniquenessOfField:unique.field]){
            valid = NO;
        }
    }
    return valid;
}

- (BOOL)validatePresence {
    BOOL valid = YES;
    for(ARValidationPresence *presence in [[self class] presenceFields]){
        if(![self isValidPresenceOfField:presence.field]){
            valid = NO;
        }
    }
    return valid;
}

#pragma mark - Save/Update

- (BOOL)save {
    if(!isNew){
        return [self update];
    }
    if(![self isValid]){
        return NO;
    }
    self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sql = [self sqlOnSave];
    if(NULL != sql){
        NSNumber *tmpId = [[ARDatabaseManager sharedInstance] 
                          insertRecord:[[self class] tableName] 
                           withSqlQuery:sql];
        self.id = self.id == nil ? tmpId : self.id;
        isNew = NO;
        return YES;
    }
    return NO;
}

- (BOOL)update {
    if(![self isValid]){
        return NO;
    }
    if(![changedFields count]){
        return YES;
    }
    self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sql = [self sqlOnUpdate];
    if(NULL != sql){
        [[ARDatabaseManager sharedInstance] executeSqlQuery:sql];
        isNew = NO;
        [changedFields removeAllObjects];
        return YES;
    }
    return NO;
}

+ (NSInteger)count {
    return [[ARDatabaseManager sharedInstance] countOfRecordsWithName:[[self class] description]];
}

#pragma mark - Relationships

#pragma mark BelongsTo

- (id)belongsTo:(NSString *)aClassName {
    NSString *selectorString = [NSString stringWithFormat:@"%@Id", [aClassName lowercaseFirst]];
    SEL selector = NSSelectorFromString(selectorString);
    NSNumber *rec_id = [self performSelector:selector];
    ARLazyFetcher *fetcher = [[[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)] autorelease];
    [fetcher whereField:@"id"
           equalToValue:rec_id];
    return [[fetcher fetchRecords] first];
}

- (void)setRecord:(ActiveRecord *)aRecord 
        belongsTo:(NSString *)aRelation
{
    NSString *relId = [NSString stringWithFormat:
                       @"%@Id", 
                       [aRelation lowercaseFirst]];
    [self setValue:aRecord.id forKey:relId];
    [self update];
}

#pragma mark HasMany

- (void)addRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[self className] lowercaseFirst]];
    [aRecord setValue:self.id forKey:relationIdKey];
    [aRecord save];
}

- (void)removeRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[self className] lowercaseFirst]];
    [aRecord setValue:nil forKey:relationIdKey];
    [aRecord save];
}

- (ARLazyFetcher *)hasManyRecords:(NSString *)aClassName {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    NSString *selfId = [NSString stringWithFormat:@"%@Id", [[self class] description]];
    [fetcher whereField:selfId equalToValue:self.id];
    return [fetcher autorelease];
}

#pragma mark HasManyThrough

- (ARLazyFetcher *)hasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName {
    
    NSString *relId = [NSString stringWithFormat:@"%@Id", [aClassName lowercaseFirst]];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    [fetcher join:NSClassFromString(aRelationsipClassName)];
    [fetcher whereField:relId
               ofRecord:NSClassFromString(aRelationsipClassName)
           equalToValue:self.id];
    return [fetcher autorelease];
}

- (void)addRecord:(ActiveRecord *)aRecord 
          ofClass:(NSString *)aClassname 
          through:(NSString *)aRelationshipClassName 
{
    Class RelationshipClass = NSClassFromString(aRelationshipClassName);
    
    NSString *currentIdSelectorString = [NSString stringWithFormat:@"set%@Id:", [[self class] description]];
    NSString *relativeIdSlectorString = [NSString stringWithFormat:@"set%@Id:", aClassname];
    
    SEL currentIdSelector = NSSelectorFromString(currentIdSelectorString);
    SEL relativeIdSelector = NSSelectorFromString(relativeIdSlectorString);
    
    NSNumber *relativeRecordId = aRecord.id;
    ActiveRecord *relationshipRecord = [RelationshipClass newRecord];
    [relationshipRecord performSelector:currentIdSelector withObject:self.id];
    [relationshipRecord performSelector:relativeIdSelector withObject:relativeRecordId];
    [relationshipRecord save];
    [relationshipRecord release];
}

- (void)removeRecord:(ActiveRecord *)aRecord through:(NSString *)aClassName
{
    NSString *selfId = [NSString stringWithFormat:@"%@Id", [[self className] lowercaseFirst]];
    NSString *relId = [NSString stringWithFormat:@"%@Id", [[aRecord className] lowercaseFirst]];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(aClassName)];
    [fetcher whereField:selfId equalToValue:self.id];
    [fetcher whereField:relId equalToValue:aRecord.id];
    ActiveRecord *record = [[fetcher fetchRecords] first];
    [record dropRecord];
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *descr = [NSMutableString stringWithFormat:@"%@\n", [[self class] description]];
    NSArray *properties = [[self class] activeRecordProperties];
    for(ARObjectProperty *property in properties){
        [descr appendFormat:@"%@ => %@\n", 
        property.propertyName, 
        [self valueForKey:property.propertyName]];
    }
    return descr;
}

#pragma mark - Drop records

#warning REFACTOR!!!

+ (void)dropAllRecords {
    [[self allRecords] makeObjectsPerformSelector:@selector(dropRecord)];
    //  [[ARDatabaseManager sharedInstance] executeSqlQuery:[self sqlOnDeleteAll]];
}
 
- (void)dropRecord {
    [[ARDatabaseManager sharedInstance] executeSqlQuery:[self sqlOnDelete]];
    [self privateAfterDestroy];
}

#pragma mark - TableFields

+ (NSArray *)tableFields {
    NSArray *properties = [self activeRecordProperties];
    NSMutableArray *tableFields = [NSMutableArray arrayWithCapacity:[properties count]];
    for(ARObjectProperty *property in properties){
        if(![ignoredFields containsObject:property.propertyName]){
            [tableFields addObject:property];
        }
    }
    return tableFields;
}

#pragma mark - Storage

+ (void)registerDatabaseName:(NSString *)aDbName useDirectory:(ARStorageDirectory)aDirectory {
    BOOL isCache = YES;
    if(aDirectory == ARStorageDocuments){
        isCache = NO;
    }
    [ARDatabaseManager registerDatabase:aDbName  cachesDirectory:isCache];
}

#pragma mark - Clear database

+ (void)clearDatabase {
    [[ARDatabaseManager sharedInstance] clearDatabase];
}

@end
