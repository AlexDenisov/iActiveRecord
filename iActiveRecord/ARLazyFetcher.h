//
//  ARArray.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARWhereStatement;

typedef enum {
    ARJoinLeft,
    ARJoinRight,
    ARJoinInner,
    ARJoinOuter
} ARJoinType;

@interface ARLazyFetcher : NSObject
{
    @private
    Class recordClass;
    NSString *sqlRequest;
    //  order by
    NSMutableDictionary *orderByConditions;
    //  select
    NSMutableSet *onlyFields;
    NSMutableSet *exceptFields;
    //  join    
    ARJoinType joinType;
    Class joinClass;
    NSString *recordField;
    NSString *joinField;
    BOOL useJoin;
    //  where
    ARWhereStatement *whereStatement;
    //  limit/offset
    NSNumber *limit;
    NSNumber *offset;
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
- (NSString *)createJoinStatement;

#pragma mark - Public methods
- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

- (ARLazyFetcher *)setWhereStatement:(ARWhereStatement *)aStatement;

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues;
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues;

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                 equalToValue:(id)aValue; 

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
              notEqualToValue:(id)aValue; 

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                           in:(NSArray *)aValues;

- (ARLazyFetcher *)whereField:(NSString *)aField 
                     ofRecord:(Class)aRecord 
                        notIn:(NSArray *)aValues;

//  select

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ...;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ...;

//  by default INNER JOIN on t1.id = t2.t1_id
- (ARLazyFetcher *)join:(Class)aJoinRecord;

- (ARLazyFetcher *)join:(Class)aJoinRecord 
                useJoin:(ARJoinType)aJoinType 
                onField:(NSString *)aFirstField 
               andField:(NSString *)aSecondField;

//  by default sort ASCENDING
- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;

//  immediately fetch records
- (NSArray *)fetchRecords;

@end
