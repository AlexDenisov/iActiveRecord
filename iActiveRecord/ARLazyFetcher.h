//
//  ARArray.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARWhereStatement;

@interface ARLazyFetcher : NSObject
{
    @private
    NSNumber *limit;
    NSNumber *offset;
    Class recordClass;
    NSString *sqlRequest;
    NSMutableDictionary *orderByConditions;
    NSMutableSet *onlyFields;
    NSMutableSet *exceptFields;
    
    ARWhereStatement *whereStatement;
}

#pragma mark - Private methods
- (id)initWithRecord:(Class )aRecord;
- (id)initWithRecord:(Class)aRecord withInitialSql:(NSString *)anInitialSql;

- (NSSet *)recordFields;

- (void)buildSql;
- (NSString *)createOrderbyStatement;
- (NSString *)createWhereStatement;
- (NSString *)createLimitOffsetStatement;
- (NSString *)createSelectStatement;

#pragma mark - Public methods
- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

- (ARLazyFetcher *)setWhereStatement:(ARWhereStatement *)aStatement;

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues;
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues;

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ...;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ...;

//  by default sort ASCENDING
- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;

//  immediately fetch records
- (NSArray *)fetchRecords;

@end
