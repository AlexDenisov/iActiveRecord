//
//  ColumnSpec.mm
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
        column.setter should equal(@"setDefaultProperty:");
        column.getter should equal(@"defaultProperty");
    });
    it(@"should parse custom accessors", ^{
        [[ARSchemaManager sharedInstance] registerSchemeForRecord:[DynamicRecord class]];
        ARColumn *column = [DynamicRecord columnNamed:@"customProperty"];
        column.setter should equal(@"customSetter:");
        column.getter should equal(@"customGetter");
    });
});

SPEC_END
