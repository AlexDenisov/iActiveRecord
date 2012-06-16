//
//  ARDynamicAccessorsSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 16.06.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//


#import "Cedar-iOS/SpecHelper.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "ARDatabaseManager.h"
#import "ARSchemaManager.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"

#import "DynamicRecord.h"

SPEC_BEGIN(ARDynamicAccessorsSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Dynamic properties", ^{
    it(@"should success set value with default accessors", ^{
        NSString *defValue = @"Default";
        DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
        [record setDefaultProperty:defValue];
        expect(record.defaultProperty).toEqual(defValue);
    });
    it(@"should success set value with custom accessors", ^{
        NSString *defValue = @"Default";
        DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
        [record customSetter:defValue];
        expect(record.customGetter).toEqual(defValue);
    });
});

SPEC_END