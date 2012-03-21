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

#pragma mark - Dynamic functions proptotypes

NSArray* dynamicallyFindBy(id self, SEL _cmd, id arg);
NSArray* dynamicallyFindWhere(id self, SEL _cmd, id arg);

#pragma mark - Dynamic functions implementation

NSArray* dynamicallyFindBy(id self, SEL _cmd, id arg){
    NSString *selector = NSStringFromSelector(_cmd);
    NSString *searchKey = [selector substringFromIndex:6];
    searchKey = [searchKey stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    searchKey = [searchKey lowercaseFirst];
    NSArray *records = [[ARDatabaseManager sharedInstance] allRecordsWithName:[[self class] description] 
                                                                     whereKey:searchKey 
                                                                     hasValue:arg];
    return records;
}

NSArray* dynamicallyFindWhere(id self, SEL _cmd, id arg){
    NSString *selector = NSStringFromSelector(_cmd);
    NSString *searchKey = [selector substringFromIndex:9];
    searchKey = [searchKey stringByReplacingOccurrencesOfString:@"In:" withString:@""];
    searchKey = [searchKey stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    searchKey = [searchKey lowercaseFirst];
    NSArray *records = [[ARDatabaseManager sharedInstance] allRecordsWithName:[[self class] description] 
                                                                     whereKey:searchKey 
                                                                     in:arg];
    return records;
}

@implementation ActiveRecord

MIGRATION_HELPER
VALIDATION_HELPER

@synthesize id;

#pragma mark - IgnoreFields

- (id)init {
    self = [super init];
    if(nil != self){
        if([[self class] conformsToProtocol:@protocol(ARValidatableProtocol)]){
            [[self class] performSelector:@selector(initValidations)];
        }
        [[self class] initIgnoredFields];
    }
    return self;    
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
        changedFields = [[NSMutableSet alloc] init];
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

+ (NSString *)className {
    return [[self class] description];
}

- (NSString *)recordName {
    return [[self class] description];
}

- (void)resetErrors {
    [errorMessages release];
    errorMessages = nil;
}

- (void)addError:(NSString *)errMessage {
    if(nil == errorMessages){
        errorMessages = [[NSMutableSet alloc] init];
    }
    [errorMessages addObject:errMessage];
}

- (void)logErrors {
    for(NSString *error in errorMessages){
        NSLog(@"%@", error);
    }
}


- (void)initialize {
    
}

#pragma mark - SQLQueries

+ (const char *)sqlOnCreate {
    [self initIgnoredFields];
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"create table %@(id integer primary key ", 
                                  [self performSelector:@selector(tableName)]];
    NSArray *properties = [self activeRecordProperties];
    if([properties count] == 0){
        return NULL;
    }
    Class propertyClass = nil;
    for(ARObjectProperty *property in properties){
        if(![ignoredFields containsObject:property.propertyName])
        {
            if(![property.propertyName isEqualToString:@"id"]){
                propertyClass = NSClassFromString(property.propertyType);
                [sqlString appendFormat:@", %@ %s", property.propertyName, 
                [propertyClass performSelector:@selector(sqlType)]];
            }
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
    NSArray *properties = [[self class] activeRecordProperties];
    if([properties count] == 0){
        return NULL;
    }
    NSMutableArray *existedProperties = [[NSMutableArray alloc] init];
    ARObjectProperty *property = nil;
    for(property in properties){
        if(![ignoredFields containsObject:property.propertyName]){
            id value = [self valueForKey:property.propertyName];
            if(nil != value){
                [existedProperties addObject:property];
            }
        }
    }
    if([existedProperties count] == 0){
        return NULL;
    }
    
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"insert into %@(", 
                                  [[self class] performSelector:@selector(tableName)]];
    NSMutableString *sqlValues = [[NSMutableString alloc] initWithFormat:@" values("];
    
    int index = 0;
    property = [existedProperties objectAtIndex:index++];
    id propertyValue = [self valueForKey:property.propertyName];
    [sqlString appendFormat:@"%@", property.propertyName];
    [sqlValues appendFormat:@"%@", [propertyValue performSelector:@selector(toSql)]];
    
    for(;index < [existedProperties count];index++){
        property = [existedProperties objectAtIndex:index];
        id propertyValue = [self valueForKey:property.propertyName];
        [sqlString appendFormat:@", %@", property.propertyName];
        [ sqlValues appendFormat:@", %@", [propertyValue performSelector:@selector(toSql)]];
    }
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
    [sqlString appendFormat:@"%@=%@", propertyName, [propertyValue performSelector:@selector(toSql)]];
   
    for(;index<[updatedValues count];index++){
        propertyName = [updatedValues objectAtIndex:index++];
        propertyValue = [self valueForKey:propertyName];
        [sqlString appendFormat:@", %@=%@", propertyName, [propertyValue performSelector:@selector(toSql)]];
    }
    [sqlString appendFormat:@" WHERE id = %@", self.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnDeleteAll {
    NSString *sql = [NSString stringWithFormat:@"delete from %@", [self tableName]];
    return [sql UTF8String];
}

#pragma mark - 

+ (NSString *)tableName {
    return [NSString stringWithFormat:@"ar%@", [[self class] description]];
}

- (NSString *)tableName {
    return [[self class] tableName];
}

+ (BOOL)resolveInstanceMethod:(SEL)name {
    return NO;
}

+ (BOOL)resolveClassMethod:(SEL)aSel {
    NSString *selectorName = NSStringFromSelector(aSel);
    if([selectorName hasPrefix:@"findBy"]){
        Class selfMetaClass = objc_getMetaClass([[[self class] description]  UTF8String]);
        class_addMethod(selfMetaClass, aSel, (IMP)dynamicallyFindBy, "[]@:@");
        return YES;
    }
    if([selectorName hasPrefix:@"findWhere"]){
        Class selfMetaClass = objc_getMetaClass([[[self class] description]  UTF8String]);
        class_addMethod(selfMetaClass, aSel, (IMP)dynamicallyFindWhere, "[]@:@");
        return YES;
    }
    return [super resolveInstanceMethod:aSel];
}

+ (id)newRecord {
    Class RecordClass = [self class];
    ActiveRecord *record = [[RecordClass alloc] init];
    [record markAsNew];
    return record;
}

+ (NSArray *)allRecords {
    NSString *recordName = [[self class] description];
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:recordName];
}

+ (id)findById:(NSNumber *)anId{
  NSString *recordName = [[self class] description];
  return [[ARDatabaseManager sharedInstance] findRecord:recordName byId:anId];
}

+ (NSArray *)findWhereIdIn:(NSArray *)aValues {
    NSString *recordName = [[self class] description];
    return [[ARDatabaseManager sharedInstance] allRecordsWithName:recordName
                                                         whereKey:@"id"
                                                               in:aValues];
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
        uniqueFields = [[NSMutableSet alloc] init];
    }
    
    BOOL contains = [uniqueFields containsObject:aField];
    if(aUnique){
        if(contains){
            return;
        }
        [uniqueFields addObject:aField];
        return;
    }
    if(contains){
        [uniqueFields removeObject:aField];
        return;
    }    
}

+ (void)validateField:(NSString *)aField asPresence:(BOOL)aPresence {
    if(nil == presenceFields){
        presenceFields = [[NSMutableSet alloc] init];
    }
    BOOL contains = [presenceFields containsObject:aField];
    if(aPresence){
        if(contains){
            return;
        }
        [presenceFields addObject:aField];
        return;
    }
    if(contains){
        [presenceFields removeObject:aField];
        return;
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
    [self logErrors];
    return valid;
}

- (BOOL)isValidPresenceOfField:(NSString *)aField {
    NSString *aValue = [self valueForKey:aField];
    if(aValue == nil || [aValue length] == 0){
        NSString *errMessage = [NSString stringWithFormat:@"%@ %@", 
                                aField, 
                                AR_Error(kARFieldCantBeBlank)];
        [self addError:errMessage];
        return NO;
    }
    return YES;
}

- (BOOL)isValidUniquenessOfField:(NSString *)aField {
    NSString *recordName = [self recordName];
    id aValue = [self valueForKey:aField];
    NSArray *records = [[ARDatabaseManager sharedInstance] allRecordsWithName:recordName 
                                                                     whereKey:aField 
                                                                     hasValue:aValue];
    if([records count]){
        NSString *errMessage = [NSString stringWithFormat:@"%@ '%@' %@", 
                                aField, 
                                aValue,
                                AR_Error(kARFieldAlreadyExists)];
        [self addError:errMessage];
        return NO;
    }
    return YES;
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
    NSString *stringSelector = [NSString stringWithFormat:@"%@Id", [aClassName lowercaseFirst]];
    SEL selector = NSSelectorFromString(stringSelector);
    Class Record = NSClassFromString(aClassName);
    id rec_id = [self performSelector:selector];
    id record = [Record findById:rec_id];
    return record;
}

#pragma mark HasMany

- (void)addRecord:(ActiveRecord *)aRecord {
    NSString *relationIdKey = [NSString stringWithFormat:@"%@Id", [[[self class] description] lowercaseFirst]];
    [aRecord setValue:self.id forKey:relationIdKey];
    [aRecord save];
}

- (NSArray *)hasManyRecords:(NSString *)aClassName {
    return nil;
}

#pragma mark HasManyThrough

- (NSArray *)hasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName {
    Class RelativeClass = NSClassFromString(aClassName);
    Class Relationship = NSClassFromString(aRelationsipClassName);
    
    NSMutableArray *relativeObjects = [[NSMutableArray alloc] init];
    
    NSString *stringSelector = [NSString stringWithFormat:@"findBy%@Id:", [[self class] description]];
    
    SEL selector = NSSelectorFromString(stringSelector);
    
    NSNumber *recId = self.id;
    
    NSArray *relationships = [Relationship performSelector:selector 
                                                withObject:recId];
    
    NSString *relativeStringSelector = [NSString stringWithFormat:@"%@Id", [aClassName lowercaseFirst]];
    SEL relativeIdSelector = NSSelectorFromString(relativeStringSelector);
    for(id rel in relationships)
    {
        id recordId = [rel performSelector:relativeIdSelector];
        id tmpRelativeObject = [RelativeClass performSelector:@selector(findById:) withObject:recordId];
        [relativeObjects addObject:tmpRelativeObject];
    }
    return relativeObjects;
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

#pragma mark - Lazy Fetching

+ (ARLazyFetcher *)lazyFetcher {
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:[self class]];
    return fetcher;
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
