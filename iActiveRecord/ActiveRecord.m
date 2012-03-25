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


@interface ActiveRecord (Private)

#pragma mark - Validations Declaration

- (BOOL)validateOnSave;
- (BOOL)validateOnUpdate;
- (BOOL)validateUniqueness;
- (BOOL)validatePresence;
- (BOOL)isValidUniquenessOfField:(NSString *)aField;
- (BOOL)isValidPresenceOfField:(NSString *)aField;

- (void)resetErrors;
- (void)addError:(ARError *)anError;

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

@end

@implementation ActiveRecord

migration_helper
validation_helper

@synthesize id;

#pragma mark - Initialize

+ (void)initialize {
    [super initialize];
    [self initIgnoredFields];
    if([self conformsToProtocol:@protocol(ARValidatableProtocol)]){
        [self performSelector:@selector(initValidations)];
    }
}

#pragma mark - IgnoreFields

- (id)init {
    self = [super init];
    if(nil != self){
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
                                  [self performSelector:@selector(tableName)]];
    NSArray *properties = [self activeRecordProperties];
    if([properties count] == 0){
        return NULL;
    }
    Class propertyClass = nil;
    for(ARObjectProperty *property in [self tableFields]){
        if(![property.propertyName isEqualToString:@"id"]){
            propertyClass = NSClassFromString(property.propertyType);
            [sqlString appendFormat:@", %@ %s", property.propertyName, 
            [propertyClass performSelector:@selector(sqlType)]];
        }
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

- (const char *)sqlOnDelete {
    NSString *sqlString = [NSString stringWithFormat:
                           @"delete from %@ where id = %@", 
                           [self tableName], 
                           self.id];
    return [sqlString UTF8String];
}

- (const char *)sqlOnSave {
    NSArray *properties = [[self class] tableFields];
    if([properties count] == 0){
        return NULL;
    }
    NSMutableArray *existedProperties = [NSMutableArray new];
    ARObjectProperty *property = nil;
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
                                  [self tableName]];
    NSMutableString *sqlValues = [NSMutableString stringWithFormat:@" VALUES("];
    
    int index = 0;
    property = [existedProperties objectAtIndex:index++];
    id propertyValue = [self valueForKey:property.propertyName];
    [sqlString appendFormat:@"%@", property.propertyName];
    [sqlValues appendFormat:@"%@", [propertyValue performSelector:@selector(toSql)]];
    
    for(;index < [existedProperties count];index++){
        property = [existedProperties objectAtIndex:index];
        id propertyValue = [self valueForKey:property.propertyName];
        [sqlString appendFormat:@", %@", property.propertyName];
        [sqlValues appendFormat:@", %@", [propertyValue performSelector:@selector(toSql)]];
    }
    [existedProperties release];
    [sqlValues appendString:@") "];
    [sqlString appendString:@") "];
    [sqlString appendString:sqlValues];
    return [sqlString UTF8String];
}

- (const char *)sqlOnUpdate {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", 
                                  [[self class] performSelector:@selector(tableName)]];
    NSArray *updatedValues = [changedFields allObjects];
    NSInteger index = 0;
    NSString *propertyName = [updatedValues objectAtIndex:index++];
    id propertyValue = [self valueForKey:propertyName];
    [sqlString appendFormat:@"%@='%@'", propertyName, [propertyValue performSelector:@selector(toSql)]];
   
    for(;index<[updatedValues count];index++){
        propertyName = [updatedValues objectAtIndex:index++];
        propertyValue = [self valueForKey:propertyName];
        [sqlString appendFormat:@", %@='%@'", propertyName, [propertyValue performSelector:@selector(toSql)]];
    }
    [sqlString appendFormat:@" WHERE id = %@", self.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnDeleteAll {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", [self tableName]];
    return [sql UTF8String];
}

#pragma mark - 

+ (NSString *)tableName {
    return [NSString stringWithFormat:@"ar%@", [[self class] description]];
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

+ (void)validateField:(NSString *)aField asUnique:(BOOL)aUnique {
    if(nil == uniqueFields){
        uniqueFields = [NSMutableSet new];
    }
    if(aUnique){
        [uniqueFields addObject:aField];
    }else{
        [uniqueFields removeObject:aField];
    }
}

+ (void)validateField:(NSString *)aField asPresence:(BOOL)aPresence {
    if(nil == presenceFields){
        presenceFields = [NSMutableSet new];
    }
    if(aPresence){
        [presenceFields addObject:aField];
    }else{
        [presenceFields removeObject:aField];
    }
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
    NSArray *records =  [fetcher fetchRecords];
    [fetcher release];
#warning TODO: implement count in ARLazyFetcher
    if([records count]){
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
        if([presenceFields containsObject:aField]){
            if(![self isValidPresenceOfField:aField]){
                valid = NO;
            }
        }
        if([uniqueFields containsObject:aField]){
            if(![self isValidUniquenessOfField:aField]){
                valid = NO;
            }
        }
    }
    return valid;
}

- (BOOL)validateUniqueness {
    BOOL valid = YES;
    for(NSString *uniqueField in uniqueFields){
        if(![self isValidUniquenessOfField:uniqueField]){
            valid = NO;
        }
    }
    return valid;
}

- (BOOL)validatePresence {
    BOOL valid = YES;
    for(NSString *presenceField in presenceFields){
        if(![self isValidPresenceOfField:presenceField]){
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
    const char *sql = [self sqlOnSave];
    if(NULL != sql){
        NSNumber *tmpId = [[ARDatabaseManager sharedInstance] 
                          insertRecord:[[self class] tableName] withSqlQuery:sql];
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
    const char *sql = [self sqlOnUpdate];
    if(NULL != sql){
        [[ARDatabaseManager sharedInstance] executeSqlQuery:sql];
        isNew = NO;
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

#pragma mark HasMany

- (void)addRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[[self class] description] lowercaseFirst]];
    [aRecord setValue:self.id forKey:relationIdKey];
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

+ (void)dropAllRecords {
    [[ARDatabaseManager sharedInstance] executeSqlQuery:[self sqlOnDeleteAll]];
}
 
- (void)dropRecord {
    [[ARDatabaseManager sharedInstance] executeSqlQuery:[self sqlOnDelete]];
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

@end
