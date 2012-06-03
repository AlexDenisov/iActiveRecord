//
//  ARLazyFetcher_Private.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARLazyFetcher.h"

@class ARWhereStatement;

static const char *joins[] = {"LEFT", "RIGHT", "INNER", "OUTER"};

static NSString* joinString(ARJoinType type) 
{
    return [NSString stringWithUTF8String:joins[type]];
}

@interface ARLazyFetcher ()
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

- (NSSet *)recordFields;

- (void)buildSql;
- (NSString *)createOrderbyStatement;
- (NSString *)createWhereStatement;
- (NSString *)createLimitOffsetStatement;
- (NSString *)createSelectStatement;
- (NSString *)createJoinedSelectStatement;
- (NSString *)createJoinStatement;

- (NSSet *)fieldsOfRecord:(id)aRecord;

@end