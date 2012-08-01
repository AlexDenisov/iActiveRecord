//
//  DynamicAccessorSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "Cedar-iOS/SpecHelper.h"
#import "ARDatabaseManager.h"
#import "ARSchemaManager.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"
#import "DynamicRecord.h"

using namespace Cedar::Matchers;

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
        record.defaultProperty should equal(defValue);
    });
    it(@"should success set value with custom accessors", ^{
        NSString *defValue = @"Default";
        DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
        [record customSetter:defValue];
        record.customGetter should equal(defValue);
    });
    it(@"should have right retainCount", ^{
        DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
        it(@"at copied property", ^{
            NSMutableString *string = [NSMutableString string];
            [string appendFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
            record.copiedString = string;
            NSInteger retainCount = string.retainCount;
            retainCount should equal(1);
        });
        it(@"at retained property", ^{
            NSMutableString *string = [NSMutableString string];
            [string appendFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
            record.retainedString = string;
            NSInteger retainCount = string.retainCount;
            retainCount should equal(2);
        });
        it(@"at assigned property", ^{
            NSMutableString *string = [NSMutableString string];
            [string appendFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
            record.assignedString = string;
            NSInteger retainCount = string.retainCount;
            retainCount should equal(1);
        });
    });
});

SPEC_END
