//
//  ARLazyFetcher.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ARJoinLeft,
    ARJoinRight,
    ARJoinInner,
    ARJoinOuter
} ARJoinType;

@interface ARLazyFetcher : NSObject

- (id)initWithRecord:(Class )aRecord;

- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

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

- (ARLazyFetcher *)where:(NSString *)aCondition, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)fetchRecords;
- (NSArray *)fetchJoinedRecords;
- (NSInteger)count;

@end
