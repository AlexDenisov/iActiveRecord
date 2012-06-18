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
    it(@"should have right retainCount", ^{
        //  this manipulations used to prevent 
        //  from compiler optimizations and have an actual retainCount
        NSLog(@"FUUUUBAR");
        NSMutableString *copy = [NSMutableString string];
        [copy appendFormat:@"%d", [NSDate timeIntervalSinceReferenceDate]];
        NSMutableString *retain = [NSMutableString string];
        [retain appendFormat:@"%d", [NSDate timeIntervalSinceReferenceDate]];
        NSMutableString *assign = [NSMutableString string];
        [assign appendFormat:@"%d", [NSDate timeIntervalSinceReferenceDate]];
        DynamicRecord *record = [[DynamicRecord newRecord] autorelease];
        record.copiedString = copy;
        NSLog(@"WTF!!! : %d", copy.retainCount);
        expect(copy.retainCount).toEqual(2);
        record.retainedString = retain;
        expect([retain retainCount]).toEqual(2);
        record.assignedString = assign;
        expect([assign retainCount]).toEqual(2);
        NSLog(@"BAAAARFUUUU");
    });
});

SPEC_END