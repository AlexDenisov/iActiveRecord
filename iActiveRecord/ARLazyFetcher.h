//
//  ARLazyFetcher.h
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

- (id)initWithRecord:(Class )aRecord;

- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

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

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ...;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ...;

//  by default INNER JOIN on t1.id = t2.t1_id
- (ARLazyFetcher *)join:(Class)aJoinRecord;

//  supports ON with one field only
//  ON t1.col = t2.col
- (ARLazyFetcher *)join:(Class)aJoinRecord 
                useJoin:(ARJoinType)aJoinType 
                onField:(NSString *)aFirstField 
               andField:(NSString *)aSecondField;

- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;// ASC by default

- (ARWhereStatement *)whereStatement;
- (ARLazyFetcher *)setWhereStatement:(ARWhereStatement *)aStatement;

- (NSArray *)fetchRecords;
- (NSInteger)count;

@end
