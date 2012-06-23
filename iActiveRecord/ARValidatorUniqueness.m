//
//  ARValidatorUniqueness.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARValidatorUniqueness.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import "ActiveRecord.h"

@implementation ARValidatorUniqueness

- (NSString *)errorMessage {
    return kARFieldAlreadyExists;
}

- (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
    NSString *recordName = [[aRecord class] description];
    id aValue = [aRecord valueForKey:aField];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(recordName)];

    // Do not include records whose id matches aRecord id, if aRecord is not new.
    if ([aRecord isKindOfClass:[ActiveRecord class]]) {
        ActiveRecord *record = (ActiveRecord *)aRecord;
        if (record.id != nil && [record.id intValue] > 0) {
            ARWhereStatement *fieldWhere = [ARWhereStatement whereField:aField ofRecord:NSClassFromString(recordName) equalToValue:aValue];
            ARWhereStatement *idWhere = [ARWhereStatement whereField:@"id" ofRecord:NSClassFromString(recordName) equalToValue:aValue];
            ARWhereStatement *finalWhere = [ARWhereStatement concatenateStatement:fieldWhere withStatement:idWhere useLogicalOperation:ARLogicalAnd];
            [fetcher setWhereStatement:finalWhere];
        }
    }

    // Fallback to previous check statement.
    if (![fetcher whereStatement]) {
        [fetcher whereField:aField equalToValue:aValue];
    }
    
    NSInteger count = [fetcher count];
    [fetcher release];
    if(count){
        return NO;
    }
    return YES;
}

@end
