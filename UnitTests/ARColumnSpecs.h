//
//  ARColumnSpecs.h
//  iActiveRecord
//
//  Created by Alex Denisov on 15.06.12.
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

SPEC_BEGIN(ARColumnSpecs)

beforeEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedInstance] clearDatabase];
});

describe(@"Parse property", ^{
    it(@"should parse default accessors", ^{
        [[ARSchemaManager sharedInstance] registerSchemeForRecord:[DynamicRecord class]];
        ARColumn *column = [DynamicRecord columnNamed:@"defaultProperty"];
        expect(column.setter).toEqual(@"setDefaultProperty:");
        expect(column.getter).toEqual(@"defaultProperty");
    });
    it(@"should parse custom accessors", ^{
        [[ARSchemaManager sharedInstance] registerSchemeForRecord:[DynamicRecord class]];
        ARColumn *column = [DynamicRecord columnNamed:@"customProperty"];
        expect(column.setter).toEqual(@"customSetter:");
        expect(column.getter).toEqual(@"customGetter");
    });
});

SPEC_END