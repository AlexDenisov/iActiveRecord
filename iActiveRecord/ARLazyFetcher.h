//
//  ARArray.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLazyFetcher : NSObject
{
    @private
    NSNumber *limit;
    NSNumber *offset;
    Class record;
    NSString *sqlRequest;
    NSMutableDictionary *orderByConditions;
    
    //  not implemented yet
    NSMutableDictionary *whereConditions;
}

#pragma mark - Private methods
- (id)initWithRecord:(Class )aRecord;
- (void)buildSql;

#pragma mark - Public methods
- (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;
- (ARLazyFetcher *)whereField:(NSString *)aField hasValue:(id)aValue; 
- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;

- (NSArray *)fetchRecords;

@end
