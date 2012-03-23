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
    
    ARWhereStatement *whereStatement;
    
    //  not implemented yet
    NSMutableDictionary *whereHasConditions;
    NSMutableDictionary *whereInConditions;
    NSMutableDictionary *whereNotInConditions;
}

#pragma mark - Private methods
- (id)initWithRecord:(Class )aRecord;
- (id)initWithRecord:(Class)aRecord withInitialSql:(NSString *)anInitialSql;

- (void)buildSql;
- (NSString *)createOrderbyStatement;
- (NSString *)createWhereStatement;
- (NSString *)createLimitOffsetStatement;

#pragma mark - Public methods
- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

//  not implemented yet

- (ARLazyFetcher *)setWhereStatement:(ARWhereStatement *)aStatement;

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue; 
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues;
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues;

//  by default sort ASCENDING
- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;

//  immediately fetch records
- (NSArray *)fetchRecords;

@end
