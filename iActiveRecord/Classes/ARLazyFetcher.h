//
//  ARLazyFetcher.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ARJoinLeft,
    ARJoinRight,
    ARJoinInner,
    ARJoinOuter
} ARJoinType;

@interface ARLazyFetcher : NSObject

- (instancetype)initWithRecord:(Class )aRecord;

- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)join:(Class)aJoinRecord;

- (ARLazyFetcher *)join:(Class)aJoinRecord
                useJoin:(ARJoinType)aJoinType
                onField:(NSString *)aFirstField
               andField:(NSString *)aSecondField;

- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;
- (ARLazyFetcher *)orderByRandom;

- (ARLazyFetcher *)where:(NSString *)aCondition, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)fetchRecords;
- (NSArray *)fetchJoinedRecords;
- (NSInteger)count;

@end
